"""Uninstall Shiny Server on Linux."""

from __future__ import annotations

import os
import subprocess


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall Shiny Server on Linux."""
    if os.path.isfile("/etc/debian_version"):
        subprocess.run(
            ["sudo", "apt-get", "purge", "-y", "shiny-server"],
            check=False,
        )
        subprocess.run(
            ["sudo", "apt-get", "autoremove", "-y"],
            check=False,
        )
        subprocess.run(["sudo", "apt-get", "clean"], check=False)
    elif os.path.isfile("/etc/fedora-release") or os.path.isfile(
        "/etc/redhat-release"
    ):
        subprocess.run(
            ["sudo", "dnf", "remove", "-y", "shiny-server"],
            check=False,
        )
    else:
        msg = "Unsupported Linux distribution."
        raise RuntimeError(msg)
