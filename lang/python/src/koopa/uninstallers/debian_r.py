"""Uninstall R on Debian."""

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
    """Uninstall R on Debian."""
    for path in ("/etc/R", "/usr/lib/R"):
        if os.path.exists(path):
            rm(path, sudo=True)
    subprocess.run(
        ["sudo", "apt-get", "purge", "-y", "r-*"],
        check=False,
    )
    subprocess.run(
        ["sudo", "apt-get", "autoremove", "-y"],
        check=False,
    )
    subprocess.run(["sudo", "apt-get", "clean"], check=False)
    repo_file = "/etc/apt/sources.list.d/koopa-r.list"
    if os.path.exists(repo_file):
        rm(repo_file, sudo=True)
