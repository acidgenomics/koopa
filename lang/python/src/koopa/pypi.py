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

_PROFILE = "acidgenomics"
_INDEX_URL = "https://python.acidgenomics.com/"


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


def _bucket() -> str:
    """Return the Python package S3 bucket name (loaded from environment)."""
    from koopa.aws import koopa_s3_bucket

    return koopa_s3_bucket("python")


def _s3_uri() -> str:
    """Return the S3 URI prefix for the Python package bucket."""
    return f"s3://{_bucket()}"


def _cloudfront_distribution_id() -> str:
    """Return CloudFront distribution ID from environment, raising if absent."""
    from koopa.aws import load_dotenv

    load_dotenv()
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
    """List all filenames under the Python package S3 bucket's packages/ prefix."""
    aws = _aws()
    result = subprocess.run(
        [
            aws,
            "s3api",
            "list-objects-v2",
            "--bucket",
            _bucket(),
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
            f"{_s3_uri()}/{key}",
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
    """Write PEP 503 simple index HTML tree to output_dir/.

    The index is served at the domain root (no /simple/ prefix), so the
    package pages live at /<name>/index.html and link to ../packages/<file>.
    """
    output_dir.mkdir(parents=True, exist_ok=True)

    # Root index
    with open(output_dir / "index.html", "w") as fh:
        fh.write("<!DOCTYPE html>\n<html>\n<body>\n")
        for name in sorted(packages):
            fh.write(f'<a href="{name}/">{name}</a>\n')
        fh.write("</body>\n</html>\n")

    # Per-package index
    for name, files in packages.items():
        pkg_dir = output_dir / name
        pkg_dir.mkdir(exist_ok=True)
        with open(pkg_dir / "index.html", "w") as fh:
            fh.write("<!DOCTYPE html>\n<html>\n<body>\n")
            for filename, sha256 in sorted(files):
                fh.write(f'<a href="../packages/{filename}#sha256={sha256}">{filename}</a>\n')
            fh.write("</body>\n</html>\n")


def _sync_index_to_s3(index_dir: Path) -> None:
    """Sync the index tree to S3 bucket root.

    The ``--exclude "packages/*"`` guard is required so that ``--delete``
    at the bucket root does not wipe uploaded wheel/sdist files.
    """
    aws = _aws()
    subprocess.run(
        [
            aws,
            "s3",
            f"--profile={_PROFILE}",
            "sync",
            "--delete",
            "--exclude",
            "packages/*",
            "--content-type",
            "text/html",
            str(index_dir) + "/",
            f"{_s3_uri()}/",
        ],
        check=True,
    )


def _invalidate_cloudfront() -> None:
    """Invalidate /* in CloudFront."""
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
            "/*",
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


def _docs_bucket() -> str:
    """Return the Python docs S3 bucket name (loaded from environment)."""
    from koopa.aws import koopa_s3_bucket

    return koopa_s3_bucket("python-docs")


def _docs_s3_uri() -> str:
    """Return the S3 URI prefix for the Python docs bucket."""
    return f"s3://{_docs_bucket()}"


def _docs_distribution_id() -> str:
    """Return CloudFront distribution ID for the docs site, raising if absent."""
    from koopa.aws import load_dotenv

    load_dotenv()
    dist_id = os.environ.get("AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON_DOCS", "")
    if not dist_id:
        dist_id = os.environ.get("AWS_CLOUDFRONT_DISTRIBUTION_ID", "")
    if not dist_id:
        msg = (
            "AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON_DOCS "
            "(or AWS_CLOUDFRONT_DISTRIBUTION_ID) must be set."
        )
        raise RuntimeError(msg)
    return dist_id


def _invalidate_cloudfront_docs() -> None:
    """Invalidate /* in the docs CloudFront distribution."""
    aws = _aws()
    dist_id = _docs_distribution_id()
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
            "/*",
            f"--profile={_PROFILE}",
        ],
        check=True,
    )


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

        dist_files = sorted(
            f for f in Path(dist_dir).iterdir() if f.suffix == ".whl" or f.name.endswith(".tar.gz")
        )
        if not dist_files:
            msg = "uv build produced no output files."
            raise RuntimeError(msg)

        for f in dist_files:
            dest = f"{_s3_uri()}/packages/{f.name}"
            alert(f"Uploading '{f.name}' to '{dest}'.")
            subprocess.run(
                [
                    aws,
                    "s3",
                    f"--profile={_PROFILE}",
                    "cp",
                    "--content-type",
                    "application/octet-stream",
                    str(f),
                    dest,
                ],
                check=True,
            )
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    reindex(invalidate=invalidate)


def publish_docs(package_dir: str, *, invalidate: bool = True) -> None:
    """Build and publish a package's Sphinx docs to python-docs.acidgenomics.com.

    The rendered site is synced to s3://<docs-bucket>/<name>/ where <name> is the
    PEP 503-normalised project name read from pyproject.toml.  The package index
    at python.acidgenomics.com is not touched.

    Parameters
    ----------
    package_dir
        Path to a Python package source directory (must contain pyproject.toml
        and a ``docs/`` directory with a Sphinx ``conf.py``).
    invalidate
        Whether to invalidate the CloudFront cache after uploading.
    """
    import tomllib

    from koopa.alert import alert
    from koopa.aws import aws_s3_sync

    pkg_path = Path(package_dir).resolve()
    pyproject = pkg_path / "pyproject.toml"
    if not pyproject.is_file():
        msg = f"No pyproject.toml found in '{pkg_path}'."
        raise FileNotFoundError(msg)
    if not (pkg_path / "docs" / "conf.py").is_file():
        msg = f"No docs/conf.py found in '{pkg_path}'."
        raise FileNotFoundError(msg)

    with open(pyproject, "rb") as fh:
        meta = tomllib.load(fh)
    raw_name = meta.get("project", {}).get("name", "")
    if not raw_name:
        msg = f"[project] name not found in '{pyproject}'."
        raise RuntimeError(msg)
    name = _normalize_name(raw_name)

    uv = _uv()
    tmp_dir = tempfile.mkdtemp()
    try:
        out_dir = os.path.join(tmp_dir, "html")
        alert(f"Building Sphinx docs for '{name}' in '{pkg_path}'.")
        subprocess.run(
            [uv, "run", "--extra", "docs", "sphinx-build", "-W", "-b", "html", "docs/", out_dir],
            cwd=str(pkg_path),
            check=True,
        )

        dest = f"{_docs_s3_uri()}/{name}/"
        alert(f"Syncing docs to '{dest}'.")
        aws_s3_sync(out_dir + "/", dest, delete=True, profile=_PROFILE)

        if invalidate:
            alert("Invalidating CloudFront docs cache.")
            _invalidate_cloudfront_docs()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    alert(f"Docs published: https://python-docs.acidgenomics.com/{name}/")
