"""Uninstall Wine on Debian."""

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
    """Uninstall Wine on Debian."""
    subprocess.run(
        ["sudo", "apt-get", "purge", "-y", "wine-*"],
        check=False,
    )
    subprocess.run(
        ["sudo", "apt-get", "autoremove", "-y"],
        check=False,
    )
    subprocess.run(["sudo", "apt-get", "clean"], check=False)
    for repo_name in ("wine", "wine-obs"):
        repo_file = f"/etc/apt/sources.list.d/koopa-{repo_name}.list"
        if os.path.exists(repo_file):
            rm(repo_file, sudo=True)
