"""Install wine."""

from __future__ import annotations

import subprocess

from koopa.system import is_debian_like, is_fedora_like


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install wine."""
    if is_debian_like():
        _install_debian()
    elif is_fedora_like():
        _install_fedora()
    else:
        msg = "Wine installation only supported on Debian-like and Fedora-like systems."
        raise RuntimeError(msg)


def _install_debian() -> None:
    subprocess.run(["sudo", "dpkg", "--add-architecture", "i386"], check=True)
    subprocess.run(
        ["sudo", "mkdir", "-p", "/etc/apt/keyrings"],
        check=True,
    )
    subprocess.run(
        [
            "sudo",
            "wget",
            "-O",
            "/etc/apt/keyrings/winehq-archive.key",
            "https://dl.winehq.org/wine-builds/winehq.key",
        ],
        check=True,
    )
    codename = ""
    with open("/etc/os-release") as f:
        for line in f:
            if line.startswith("VERSION_CODENAME="):
                codename = line.split("=", 1)[1].strip().strip('"')
                break
    subprocess.run(
        [
            "sudo",
            "wget",
            "-NP",
            "/etc/apt/sources.list.d/",
            (
                f"https://dl.winehq.org/wine-builds/ubuntu/dists/"
                f"{codename}/winehq-{codename}.sources"
            ),
        ],
        check=True,
    )
    subprocess.run(["sudo", "apt-get", "update", "-y"], check=True)
    subprocess.run(
        ["sudo", "apt-get", "install", "-y", "--install-recommends", "winehq-stable"],
        check=True,
    )


def _install_fedora() -> None:
    fedora_ver = ""
    with open("/etc/os-release") as f:
        for line in f:
            if line.startswith("VERSION_ID="):
                fedora_ver = line.split("=", 1)[1].strip().strip('"')
                break
    subprocess.run(
        [
            "sudo",
            "dnf",
            "config-manager",
            "--add-repo",
            f"https://dl.winehq.org/wine-builds/fedora/{fedora_ver}/winehq.repo",
        ],
        check=True,
    )
    subprocess.run(
        ["sudo", "dnf", "install", "-y", "winehq-stable"],
        check=True,
    )
