"""Shared helpers for build-from-source installers."""

import os
from glob import glob
from urllib.parse import urlparse

from koopa.archive import extract
from koopa.download import download, download_with_mirror


def download_extract_cd(url: str) -> None:
    """Download a tarball, extract into ``src/``, and chdir into it."""
    from koopa.installers._context import get_app_name

    name = get_app_name()
    if name:
        filename = os.path.basename(urlparse(url).path)
        tarball = download_with_mirror(url, name, filename)
    else:
        tarball = download(url)
    extract_cd(tarball)


def extract_cd(tarball: str) -> None:
    """Extract a tarball into ``src/`` and chdir into it."""
    extract(tarball, "src")
    os.chdir("src")


def remove_static_libs(prefix: str) -> None:
    """Remove static ``.a`` libraries from prefix lib directory."""
    for f in glob(os.path.join(prefix, "lib", "*.a")):
        os.unlink(f)
