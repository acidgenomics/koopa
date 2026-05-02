"""Uninstall Wine on Fedora."""

from __future__ import annotations

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
    """Uninstall Wine on Fedora."""
    pkgs = [
        "winehq-stable",
        "xorg-x11-apps",
        "xorg-x11-server-Xvfb",
        "xorg-x11-xauth",
    ]
    subprocess.run(
        ["sudo", "dnf", "remove", "-y", *pkgs],
        check=False,
    )
    repo_file = "/etc/yum.repos.d/winehq.repo"
    if os.path.exists(repo_file):
        rm(repo_file, sudo=True)
