"""Uninstall Shiny Server on Fedora."""

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
    """Uninstall Shiny Server on Fedora."""
    subprocess.run(
        ["sudo", "dnf", "remove", "-y", "shiny-server"],
        check=False,
    )
