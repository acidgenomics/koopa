"""Uninstall RStudio Server on Debian."""

import subprocess


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall RStudio Server on Debian.

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
        ["sudo", "apt-get", "purge", "-y", "rstudio-server"],
        check=False,
    )
    subprocess.run(
        ["sudo", "apt-get", "autoremove", "-y"],
        check=False,
    )
    subprocess.run(["sudo", "apt-get", "clean"], check=False)
