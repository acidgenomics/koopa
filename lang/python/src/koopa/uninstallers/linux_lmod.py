"""Uninstall Lmod configuration."""

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
    """Uninstall Lmod configuration.

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
    lmod_sh = "/etc/profile.d/z00_lmod.sh"
    if not os.path.exists(lmod_sh):
        return
    for path in (
        "/etc/profile.d/z00_lmod.csh",
        "/etc/profile.d/z00_lmod.sh",
    ):
        if os.path.exists(path):
            rm(path, sudo=True)
