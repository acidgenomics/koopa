"""Uninstall RStudio Server on Debian."""

from __future__ import annotations

import subprocess


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall RStudio Server on Debian."""
    subprocess.run(
        ["sudo", "apt-get", "purge", "-y", "rstudio-server"],
        check=False,
    )
    subprocess.run(
        ["sudo", "apt-get", "autoremove", "-y"],
        check=False,
    )
    subprocess.run(["sudo", "apt-get", "clean"], check=False)
