"""Private PyPI index management for python.acidgenomics.com."""

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

_BUCKET = "python-REDACTED_ACCOUNT_ID-us-east-1-an"
_S3_URI = f"s3://{_BUCKET}"
_PROFILE = "acidgenomics"
_INDEX_URL = "https://python.acidgenomics.com/simple/"


def _aws() -> str:
    """Return path to aws CLI, raising if absent."""
    path = shutil.which("aws")
    if path is None:
        msg = "aws CLI is not installed."
        raise RuntimeError(msg)
    return path


def _uv() -> str:
    """Return path to uv, raising if absent."""
    path = shutil.which("uv")
    if path is None:
        msg = "uv is not installed."
        raise RuntimeError(msg)
    return path


def _cloudfront_distribution_id() -> str:
    """Return CloudFront distribution ID from environment, raising if absent."""
    dist_id = os.environ.get("AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON", "")
    if not dist_id:
        dist_id = os.environ.get("AWS_CLOUDFRONT_DISTRIBUTION_ID", "")
    if not dist_id:
        msg = (
            "AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON (or AWS_CLOUDFRONT_DISTRIBUTION_ID) must be set."
        )
        raise RuntimeError(msg)
    return dist_id


def _s3_list_packages() -> list[str]:
    """List all filenames under s3://python-REDACTED_ACCOUNT_ID-us-east-1-an/packages/."""
    aws = _aws()
    result = subprocess.run(
        [
            aws,
            "s3api",
            "list-objects-v2",
            "--bucket",
            _BUCKET,
            "--prefix",
            "packages/",
            f"--profile={_PROFILE}",
            "--output",
            "json",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    data = json.loads(result.stdout)
    keys = [obj["Key"] for obj in data.get("Contents", [])]
    return [k.removeprefix("packages/") for k in keys if k != "packages/"]


def _normalize_name(name: str) -> str:
    """PEP 503 normalized package name."""
    return re.sub(r"[-_.]+", "-", name).lower()


def _parse_package_name(filename: str) -> str | None:
    """Extract normalized package name from wheel or sdist filename."""
    # wheel: name-version(-build)?-pythontag-abitag-platformtag.whl
    # sdist: name-version.tar.gz
    match = re.match(r"^([A-Za-z0-9]([A-Za-z0-9._-]*[A-Za-z0-9])?)-\d", filename)
    if match:
        return _normalize_name(match.group(1))
    return None


def _sha256_of_s3_file(key: str, tmp_dir: str) -> str:
    """Download an S3 object and return its SHA-256 hex digest."""
    aws = _aws()
    local = os.path.join(tmp_dir, os.path.basename(key))
    subprocess.run(
        [
            aws,
            "s3",
            f"--profile={_PROFILE}",
            "cp",
            f"{_S3_URI}/{key}",
            local,
        ],
        capture_output=True,
        check=True,
    )
    h = hashlib.sha256()
    with open(local, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            h.update(chunk)
    os.unlink(local)
    return h.hexdigest()


def _generate_index(
    packages: dict[str, list[tuple[str, str]]],
    output_dir: Path,
) -> None:
    """Write PEP 503 simple index HTML tree to output_dir/simple/."""
    simple = output_dir / "simple"
    simple.mkdir(parents=True, exist_ok=True)

    # Root index
    with open(simple / "index.html", "w") as fh:
        fh.write("<!DOCTYPE html>\n<html>\n<body>\n")
        for name in sorted(packages):
            fh.write(f'<a href="{name}/">{name}</a>\n')
        fh.write("</body>\n</html>\n")

    # Per-package index
    for name, files in packages.items():
        pkg_dir = simple / name
        pkg_dir.mkdir(exist_ok=True)
        with open(pkg_dir / "index.html", "w") as fh:
            fh.write("<!DOCTYPE html>\n<html>\n<body>\n")
            for filename, sha256 in sorted(files):
                fh.write(f'<a href="../../packages/{filename}#sha256={sha256}">{filename}</a>\n')
            fh.write("</body>\n</html>\n")


def _sync_index_to_s3(index_dir: Path) -> None:
    """Sync the simple/ index tree to S3."""
    aws = _aws()
    simple_dir = str(index_dir / "simple") + "/"
    subprocess.run(
        [
            aws,
            "s3",
            f"--profile={_PROFILE}",
            "sync",
            "--delete",
            "--content-type",
            "text/html",
            simple_dir,
            f"{_S3_URI}/simple/",
        ],
        check=True,
    )


def _invalidate_cloudfront() -> None:
    """Invalidate /simple/* in CloudFront."""
    aws = _aws()
    dist_id = _cloudfront_distribution_id()
    subprocess.run(
        [
            aws,
            "cloudfront",
            "create-invalidation",
            "--distribution-id",
            dist_id,
            "--no-cli-pager",
            "--output",
            "text",
            "--paths",
            "/simple/*",
            f"--profile={_PROFILE}",
        ],
        check=True,
    )


def reindex(*, invalidate: bool = True) -> None:
    """Regenerate the PEP 503 index from current S3 bucket contents.

    Parameters
    ----------
    invalidate
        Whether to invalidate the CloudFront cache after syncing.
    """
    from koopa.alert import alert

    alert("Listing packages in S3.")
    filenames = _s3_list_packages()
    if not filenames:
        print("No packages found in S3 bucket.", file=sys.stderr)
        return

    tmp_dir = tempfile.mkdtemp()
    try:
        alert("Computing SHA-256 hashes.")
        packages: dict[str, list[tuple[str, str]]] = {}
        for filename in sorted(filenames):
            name = _parse_package_name(filename)
            if name is None:
                print(f"Warning: skipping unrecognized file '{filename}'", file=sys.stderr)
                continue
            sha256 = _sha256_of_s3_file(f"packages/{filename}", tmp_dir)
            packages.setdefault(name, []).append((filename, sha256))

        index_dir = Path(tmp_dir) / "index"
        alert("Generating PEP 503 index HTML.")
        _generate_index(packages, index_dir)

        alert("Syncing index to S3.")
        _sync_index_to_s3(index_dir)

        if invalidate:
            alert("Invalidating CloudFront cache.")
            _invalidate_cloudfront()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    alert(f"Index updated. Packages: {sorted(packages)}")


def publish(package_dir: str, *, invalidate: bool = True) -> None:
    """Build and publish a Python package to python.acidgenomics.com.

    Parameters
    ----------
    package_dir
        Path to a Python package source directory (must contain pyproject.toml).
    invalidate
        Whether to invalidate the CloudFront cache after uploading.
    """
    from koopa.alert import alert

    pkg_path = Path(package_dir).resolve()
    if not (pkg_path / "pyproject.toml").is_file():
        msg = f"No pyproject.toml found in '{pkg_path}'."
        raise FileNotFoundError(msg)

    uv = _uv()
    aws = _aws()

    tmp_dir = tempfile.mkdtemp()
    try:
        dist_dir = os.path.join(tmp_dir, "dist")
        os.makedirs(dist_dir)

        alert(f"Building package in '{pkg_path}'.")
        subprocess.run(
            [uv, "build", "--out-dir", dist_dir],
            cwd=str(pkg_path),
            check=True,
        )

        dist_files = sorted(Path(dist_dir).iterdir())
        if not dist_files:
            msg = "uv build produced no output files."
            raise RuntimeError(msg)

        for f in dist_files:
            dest = f"{_S3_URI}/packages/{f.name}"
            alert(f"Uploading '{f.name}' to '{dest}'.")
            subprocess.run(
                [aws, "s3", f"--profile={_PROFILE}", "cp", str(f), dest],
                check=True,
            )
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    reindex(invalidate=invalidate)
