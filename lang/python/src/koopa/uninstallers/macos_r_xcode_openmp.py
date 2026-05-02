"""Uninstall OpenMP for Xcode on macOS."""

from __future__ import annotations

import os

from koopa.file_ops import rm


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall OpenMP for Xcode on macOS."""
    paths = [
        "/usr/local/include/omp-tools.h",
        "/usr/local/include/omp.h",
        "/usr/local/include/ompt.h",
        "/usr/local/lib/libomp.dylib",
    ]
    for path in paths:
        if os.path.lexists(path):
            rm(path, sudo=True)
