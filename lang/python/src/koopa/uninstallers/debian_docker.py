"""Uninstall Docker on Debian."""

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
    """Uninstall Docker on Debian."""
    pkgs = [
        "containerd.io",
        "docker-buildx-plugin",
        "docker-ce",
        "docker-ce-cli",
        "docker-compose-plugin",
        "containerd",
        "docker-compose",
        "docker-doc",
        "docker.io",
        "podman-docker",
        "runc",
    ]
    subprocess.run(
        ["sudo", "apt-get", "purge", "-y", *pkgs],
        check=False,
    )
    subprocess.run(
        ["sudo", "apt-get", "autoremove", "-y"],
        check=False,
    )
    subprocess.run(["sudo", "apt-get", "clean"], check=False)
    repo_file = "/etc/apt/sources.list.d/koopa-docker.list"
    if os.path.exists(repo_file):
        rm(repo_file, sudo=True)
