"""Uninstall Xcode CLT on macOS."""

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
    """Uninstall Xcode CLT on macOS.

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
    clt_dir = "/Library/Developer/CommandLineTools"
    if not os.path.exists(clt_dir):
        return
    rm(clt_dir, sudo=True)
