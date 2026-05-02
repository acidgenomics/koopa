"""Install shiny-server (system)."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.system import arch, arch2, is_debian_like, is_fedora_like


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install shiny-server."""
    machine = arch()
    machine2 = arch2()
    if is_debian_like():
        distro = "ubuntu-18.04"
        file_arch = machine2
        ext = "deb"
    elif is_fedora_like():
        distro = "centos7"
        file_arch = machine
        ext = "rpm"
    else:
        msg = "Unsupported Linux distro."
        raise RuntimeError(msg)
    url = (
        f"https://download3.rstudio.org/{distro}/{machine}/shiny-server-{version}-{file_arch}.{ext}"
    )
    rscript = shutil.which("Rscript")
    if rscript is None:
        msg = "Rscript not found. Install R first."
        raise FileNotFoundError(msg)
    print("Installing R shiny package.", file=sys.stderr)
    subprocess.run(
        [rscript, "-e", 'install.packages("shiny")'],
        check=True,
    )
    pkg_file = download(url)
    if ext == "deb":
        subprocess.run(
            ["sudo", "dpkg", "-i", os.path.basename(pkg_file)],
            cwd=os.path.dirname(pkg_file),
            check=True,
        )
    else:
        subprocess.run(
            ["sudo", "yum", "install", "-y", "--nogpgcheck", pkg_file],
            check=True,
        )
