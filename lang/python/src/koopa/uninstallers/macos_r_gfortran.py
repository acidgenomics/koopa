"""Uninstall GNU Fortran for R on macOS."""

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
    """Uninstall GNU Fortran for R on macOS."""
    gfortran_dir = "/opt/gfortran"
    if not os.path.exists(gfortran_dir):
        return
    rm(gfortran_dir, sudo=True)
