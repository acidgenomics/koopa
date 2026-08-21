"""Build and publish koopa.acidgenomics.com (the koopa Sphinx docs site).

The koopa bucket root also serves ``/install`` (curl'd by every new install)
and ``/src/<app>/<tarball>`` (the source mirror ``bootstrap.sh`` depends on),
so the docs sync never uses ``--delete``: a stale-content prune is a
separate, explicit, dry-run-by-default step that skips both reserved
prefixes and anything present in the freshly built tree.
"""

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

_PROFILE = "acidgenomics"

# Bucket-root prefixes that a prune must never delete.
_RESERVED_PREFIXES: tuple[str, ...] = ("install", "src/")


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
    """Return the koopa website S3 bucket name (loaded from environment)."""
    from koopa.aws import koopa_s3_bucket

    return koopa_s3_bucket("koopa")


def _s3_uri() -> str:
    """Return the S3 URI prefix for the koopa website bucket."""
    return f"s3://{_bucket()}"


def _cloudfront_distribution_id() -> str:
    """Return CloudFront distribution ID from environment, raising if absent.

    Deliberately does NOT fall back to a generic AWS_CLOUDFRONT_DISTRIBUTION_ID
    -- see the identical fix in koopa.pypi._cloudfront_distribution_id for why
    that fallback is unsafe (silently invalidates the wrong distribution).
    """
    from koopa.aws import dotenv_value

    dist_id = dotenv_value("AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA")
    if not dist_id:
        msg = "AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA must be set."
        raise RuntimeError(msg)
    return dist_id


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


def _build_site(koopa_root: str, out_dir: str, doctree_dir: str) -> None:
    """Regenerate docs sources and run sphinx-build against them."""
    from koopa.alert import alert
    from koopa.generate_docs import generate_docs
    from koopa.update_docs import update_docs

    alert("Regenerating CLI reference and app-stack include.")
    generate_docs()
    update_docs()

    uv = _uv()
    alert("Building Sphinx site.")
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
        cwd=koopa_root,
        check=True,
    )


def _relative_keys(root: str) -> set[str]:
    """Return the set of S3-style relative keys for every file under root."""
    keys: set[str] = set()
    for path in Path(root).rglob("*"):
        if path.is_file():
            keys.add(str(path.relative_to(root)))
    return keys


def publish_docs(*, invalidate: bool = True, dryrun: bool = False) -> None:
    """Build and publish the koopa Sphinx docs site to koopa.acidgenomics.com.

    Never syncs with ``--delete`` -- the bucket root also serves ``/install``
    and the ``/src/`` bootstrap source mirror. Use ``prune_stale`` separately
    to remove genuinely stale keys.

    Parameters
    ----------
    invalidate
        Whether to invalidate the CloudFront cache after uploading.
    dryrun
        Print the aws s3 sync plan without uploading anything.
    """
    from koopa.alert import alert
    from koopa.aws import aws_s3_sync
    from koopa.prefix import koopa_prefix

    koopa_root = koopa_prefix()
    tmp_dir = tempfile.mkdtemp()
    try:
        out_dir = os.path.join(tmp_dir, "html")
        doctree_dir = os.path.join(tmp_dir, "doctrees")
        _build_site(koopa_root, out_dir, doctree_dir)

        dest = f"{_s3_uri()}/"
        alert(f"Syncing site to '{dest}'.")
        aws_s3_sync(out_dir + "/", dest, dryrun=dryrun, profile=_PROFILE)

        if invalidate and not dryrun:
            alert("Invalidating CloudFront cache.")
            _invalidate_cloudfront()
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    if not dryrun:
        alert("Docs published: https://koopa.acidgenomics.com/")


def prune_stale(*, dryrun: bool = True) -> None:
    """Remove S3 keys that no longer correspond to a file in the built site.

    Never touches ``_RESERVED_PREFIXES`` (``install``, ``src/``), regardless
    of whether those keys appear in the freshly built site tree.

    Parameters
    ----------
    dryrun
        Print what would be deleted without deleting. Defaults to True --
        callers must opt in to an actual deletion.
    """
    from koopa.alert import alert
    from koopa.cli_develop import _list_s3_keys
    from koopa.prefix import koopa_prefix
    from koopa.text import plural

    aws = _aws()
    bucket = _bucket()
    koopa_root = koopa_prefix()

    tmp_dir = tempfile.mkdtemp()
    try:
        out_dir = os.path.join(tmp_dir, "html")
        doctree_dir = os.path.join(tmp_dir, "doctrees")
        _build_site(koopa_root, out_dir, doctree_dir)
        built_keys = _relative_keys(out_dir)

        alert("Listing all keys in the koopa website bucket.")
        remote_keys = _list_s3_keys(aws, bucket, "", _PROFILE)

        stale = {
            key
            for key in remote_keys
            if key not in built_keys and not key.startswith(_RESERVED_PREFIXES)
        }
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    if not stale:
        alert("No stale keys found.")
        return

    for key in sorted(stale):
        print(f"  s3://{bucket}/{key}", file=sys.stderr)

    n = len(stale)
    if dryrun:
        alert(
            f"Dry run: {n} stale {plural(n, 'key')} would be deleted."
            " Re-run with --no-dryrun to delete."
        )
        return

    for key in sorted(stale):
        subprocess.run(
            [aws, "s3", "rm", f"s3://{bucket}/{key}", f"--profile={_PROFILE}"],
            check=True,
        )
    alert(f"Deleted {n} stale {plural(n, 'key')}.")
