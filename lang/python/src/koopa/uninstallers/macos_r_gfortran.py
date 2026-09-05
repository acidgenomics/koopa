"""Uninstall GNU Fortran for R on macOS."""

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
    """Uninstall GNU Fortran for R on macOS.

    Parameters
    ----------
    name : str
        Application name.
    platform : str
        Operating system platform slug.
    mode : str
        Installation mode (e.g. ``"system"`` or ``"shared"``).
    prefix : str, optional
        Installation prefix directory.
    verbose : bool, optional
        Print verbose output.
    """
    gfortran_dir = "/opt/gfortran"
    if not os.path.exists(gfortran_dir):
        return
    rm(gfortran_dir, sudo=True)
