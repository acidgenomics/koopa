"""Uninstall Oracle Instant Client on Fedora."""

import os
import subprocess

from koopa.file_ops import rm


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall Oracle Instant Client on Fedora.

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
    subprocess.run(
        ["sudo", "dnf", "remove", "-y", "oracle-instantclient*"],
        check=False,
    )
    conf = "/etc/ld.so.conf.d/oracle-instantclient.conf"
    if os.path.exists(conf):
        rm(conf, sudo=True)
