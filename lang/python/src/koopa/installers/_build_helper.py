"""Shared helpers for build-from-source installers."""

from __future__ import annotations

import os
from glob import glob

from koopa.archive import extract
from koopa.download import download


def download_extract_cd(url: str) -> None:
    """Download a tarball, extract into ``src/``, and chdir into it.

    If extraction produces a single subdirectory, descend into it.
    """
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    entries = os.listdir(".")
    if len(entries) == 1 and os.path.isdir(entries[0]):
        os.chdir(entries[0])


def remove_static_libs(prefix: str) -> None:
    """Remove static ``.a`` libraries from prefix lib directory."""
    for f in glob(os.path.join(prefix, "lib", "*.a")):
        os.unlink(f)
