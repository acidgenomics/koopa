"""Private PyPI index management for python.acidgenomics.com."""

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

_PROFILE = "acidgenomics"


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


def _read_wheel_summary(whl_path: str) -> str:
    """Read the Summary field from a wheel's METADATA, returning '' if absent."""
    try:
        with zipfile.ZipFile(whl_path) as zf:
            meta_name = next(
                (n for n in zf.namelist() if n.endswith(".dist-info/METADATA")),
                None,
            )
            if meta_name is None:
                return ""
            for line in zf.read(meta_name).decode(errors="replace").splitlines():
                if line.startswith("Summary:"):
                    return line[len("Summary:") :].strip()
    except (OSError, zipfile.BadZipFile):
        pass
    return ""


def _generate_index(
    packages: dict[str, list[tuple[str, str]]],
    output_dir: Path,
) -> None:
    """Write PEP 503 simple index HTML tree to output_dir/.

    The index is served at /simple/ (PEP 503 convention), so the package
    pages live at /simple/<name>/index.html and link to ../../packages/<file>.
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
                fh.write(f'<a href="../../packages/{filename}#sha256={sha256}">{filename}</a>\n')
            fh.write("</body>\n</html>\n")


# Category groupings, mirroring r.acidgenomics.com's landing page. Packages not
# listed here (e.g. a brand-new package not yet categorized) fall into "Other" at
# the end, so nothing silently drops off the landing page.
_LANDING_CATEGORIES: list[tuple[str, list[str]]] = [
    ("Import/export", ["pipette", "acidgenomes", "acidplyr", "goalie", "syntactic"]),
    ("Annotation databases", ["cellosaurus"]),
    ("Infrastructure", ["acidbase"]),
]


def _generate_landing(
    packages_summaries: dict[str, str],
    output_path: Path,
) -> None:
    """Write the root landing page to output_path.

    Mirrors the r.acidgenomics.com structure and stylesheet: breadcrumb to
    Acid Genomics, Google site search, a categorized package list (see
    _LANDING_CATEGORIES) with descriptions linking to per-package docs, and a
    footer with the install snippet and license. css/front.css and
    images/logo.svg are uploaded separately (not part of the generated tree);
    see the module docstring for the S3 layout.
    """
    from koopa.landing import render_landing

    remaining = dict(packages_summaries)
    sections: list[tuple[str, list[tuple[str, str, str]]]] = []
    for heading, names in _LANDING_CATEGORIES:
        entries = [(name, f"{name}/", remaining.pop(name)) for name in names if name in remaining]
        if entries:
            sections.append((heading, entries))
    if remaining:
        entries = [(name, f"{name}/", remaining[name]) for name in sorted(remaining)]
        sections.append(("Other", entries))

    content = render_landing(
        "Python packages",
        sections,
        license_name="Apache 2.0",
        license_url="https://www.apache.org/licenses/LICENSE-2.0",
        copyright_years="2026-pres.",
        install_note=(
            "Install: <code>uv pip install "
            "--index-url https://python.acidgenomics.com/simple/ "
            "&lt;package&gt;</code>"
        ),
    )
    with open(output_path, "w") as fh:
        fh.write(content)


def _sync_index_to_s3(index_dir: Path) -> None:
    """Sync the PEP 503 index tree to s3://bucket/simple/.

    Scoping the sync to the simple/ prefix confines --delete to that
    subtree; packages/ and per-package docs are never touched.
    """
    aws = _aws()
    subprocess.run(
        [
            aws,
            "s3",
            f"--profile={_PROFILE}",
            "sync",
            "--delete",
            "--content-type",
            "text/html",
            str(index_dir) + "/",
            f"{_s3_uri()}/simple/",
        ],
        check=True,
    )


def _upload_landing(landing_path: Path) -> None:
    """Upload the root landing page to s3://bucket/index.html."""
    subprocess.run(
        [
            _aws(),
            "s3",
            f"--profile={_PROFILE}",
            "cp",
            "--content-type",
            "text/html",
            str(landing_path),
            f"{_s3_uri()}/index.html",
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

        alert("Reading wheel metadata for landing page.")
        aws = _aws()
        summaries: dict[str, str] = {}
        for name in sorted(packages):
            whl = next((f for f, _ in packages[name] if f.endswith(".whl")), None)
            if whl is None:
                summaries[name] = ""
                continue
            local = os.path.join(tmp_dir, whl)
            subprocess.run(
                [aws, "s3", f"--profile={_PROFILE}", "cp", f"{_s3_uri()}/packages/{whl}", local],
                capture_output=True,
                check=True,
            )
            summaries[name] = _read_wheel_summary(local)
            os.unlink(local)

        simple_dir = Path(tmp_dir) / "simple"
        alert("Generating PEP 503 index HTML.")
        _generate_index(packages, simple_dir)

        alert("Syncing index to S3.")
        _sync_index_to_s3(simple_dir)

        alert("Generating landing page.")
        landing_path = Path(tmp_dir) / "index.html"
        _generate_landing(summaries, landing_path)
        _upload_landing(landing_path)

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
    """Build and publish a package's Sphinx docs to python.acidgenomics.com.

    The rendered site is synced to s3://<python-bucket>/<name>/ where <name>
    is the PEP 503-normalised project name read from pyproject.toml. Docs are
    served at https://python.acidgenomics.com/<name>/ on the same domain and
    bucket as the package index. The index at /simple/ is not touched.

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
    if name in {"simple", "packages"}:
        msg = f"Package name '{name}' collides with a reserved path on python.acidgenomics.com."
        raise ValueError(msg)

    uv = _uv()
    tmp_dir = tempfile.mkdtemp()
    try:
        out_dir = os.path.join(tmp_dir, "html")
        doctree_dir = os.path.join(tmp_dir, "doctrees")
        alert(f"Building Sphinx docs for '{name}' in '{pkg_path}'.")
        subprocess.run(
            [
                uv,
                "run",
                "--extra",
                "docs",
                "sphinx-build",
                "-W",
                "-b",
                "html",
                "-d",
                doctree_dir,
                "docs/",
                out_dir,
            ],
            cwd=str(pkg_path),
            check=True,
        )

        dest = f"{_s3_uri()}/{name}/"
        alert(f"Syncing docs to '{dest}'.")
        aws_s3_sync(out_dir + "/", dest, delete=True, profile=_PROFILE)

        if invalidate:
            alert("Invalidating CloudFront cache.")
            _invalidate_cloudfront()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    alert(f"Docs published: https://python.acidgenomics.com/{name}/")


def publish_assets(*, invalidate: bool = True) -> None:
    """Upload shared static assets to python.acidgenomics.com.

    Uploads koopa's tracked copy of assets/sphinx.css to s3://<python-bucket>/css/sphinx.css.
    Every package's docs/conf.py references this file by absolute URL, so a single
    upload updates the theme for all published docs sites at once.

    Parameters
    ----------
    invalidate
        Whether to invalidate the CloudFront cache after uploading.
    """
    from koopa.alert import alert

    css_path = Path(__file__).parent / "assets" / "sphinx.css"
    if not css_path.is_file():
        msg = f"Asset not found: '{css_path}'."
        raise FileNotFoundError(msg)

    dest = f"{_s3_uri()}/css/sphinx.css"
    alert(f"Uploading '{css_path}' to '{dest}'.")
    subprocess.run(
        [
            _aws(),
            "s3",
            f"--profile={_PROFILE}",
            "cp",
            "--content-type",
            "text/css",
            str(css_path),
            dest,
        ],
        check=True,
    )

    if invalidate:
        alert("Invalidating CloudFront cache.")
        _invalidate_cloudfront()

    alert(f"Assets published: {dest}")
