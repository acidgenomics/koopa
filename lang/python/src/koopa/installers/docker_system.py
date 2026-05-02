"""Install docker."""

from __future__ import annotations

import os
import subprocess

from koopa.os_linux import add_user_to_group, apt_install, systemctl_enable, systemctl_start


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install docker."""
    subprocess.run(
        ["sudo", "install", "-m", "0755", "-d", "/etc/apt/keyrings"],
        check=True,
    )
    subprocess.run(
        [
            "sudo",
            "curl",
            "-fsSL",
            "https://download.docker.com/linux/ubuntu/gpg",
            "-o",
            "/etc/apt/keyrings/docker.asc",
        ],
        check=True,
    )
    subprocess.run(
        ["sudo", "chmod", "a+r", "/etc/apt/keyrings/docker.asc"],
        check=True,
    )
    codename = ""
    with open("/etc/os-release") as f:
        for line in f:
            if line.startswith("VERSION_CODENAME="):
                codename = line.split("=", 1)[1].strip().strip('"')
                break
    machine = subprocess.run(
        ["dpkg", "--print-architecture"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    repo_line = (
        f"deb [arch={machine} signed-by=/etc/apt/keyrings/docker.asc] "
        f"https://download.docker.com/linux/ubuntu {codename} stable"
    )
    with open("/tmp/docker.list", "w") as f:
        f.write(repo_line + "\n")
    subprocess.run(
        ["sudo", "cp", "/tmp/docker.list", "/etc/apt/sources.list.d/docker.list"],
        check=True,
    )
    subprocess.run(["sudo", "apt-get", "update", "-y"], check=True)
    apt_install(
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
    )
    user = os.environ.get("USER", "")
    if user:
        add_user_to_group(user, "docker")
    systemctl_enable("docker")
    systemctl_start("docker")
