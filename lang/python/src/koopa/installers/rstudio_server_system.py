"""Install rstudio-server (system)."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.download import download
from koopa.file_ops import mkdir
from koopa.system import arch, arch2, is_debian_like, is_fedora_like


def _debian_os_codename() -> str:
    with open("/etc/os-release") as f:
        for line in f:
            if line.startswith("VERSION_CODENAME="):
                return line.split("=", 1)[1].strip().strip('"')
    return ""


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install rstudio-server."""
    version_url = version.replace("+", "-")
    if is_debian_like():
        machine = arch2()
        distro = _debian_os_codename()
        distro_map = {
            "jammy": "jammy",
            "focal": "focal",
            "buster": "jammy",
            "bullseye": "jammy",
            "bookworm": "focal",
        }
        if distro not in distro_map:
            msg = f"Unsupported distro: '{distro}'."
            raise RuntimeError(msg)
        distro = distro_map[distro]
        url = (
            f"https://download2.rstudio.org/server/{distro}/"
            f"{machine}/rstudio-server-{version_url}-{machine}.deb"
        )
        pkg_file = download(url)
        subprocess.run(
            ["sudo", "dpkg", "-i", os.path.basename(pkg_file)],
            cwd=os.path.dirname(pkg_file),
            check=True,
        )
    elif is_fedora_like():
        machine = arch()
        init_dir = "/etc/init.d"
        if not os.path.isdir(init_dir):
            mkdir(init_dir, sudo=True)
        url = (
            f"https://download2.rstudio.org/server/centos8/"
            f"{machine}/rstudio-server-rhel-{version_url}-{machine}.rpm"
        )
        pkg_file = download(url)
        subprocess.run(
            ["sudo", "yum", "install", "-y", "--nogpgcheck", pkg_file],
            check=True,
        )
    else:
        msg = "Unsupported Linux distro."
        raise RuntimeError(msg)
    print("Configuring RStudio Server.", file=sys.stderr)
