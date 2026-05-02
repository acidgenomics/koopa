"""Install Aspera Connect."""

from __future__ import annotations

import os
import platform
import subprocess

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import cp, rm


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Aspera Connect."""
    machine = platform.machine()
    if machine in ("aarch64", "arm64"):
        msg = "ARM64 is not supported for Aspera Connect."
        raise RuntimeError(msg)
    arch = machine
    plat = "linux"
    aspera_user_prefix = os.path.join(os.path.expanduser("~"), ".aspera")
    script_target = os.path.join(aspera_user_prefix, "connect")
    url = (
        f"https://d3gcli72yxqn2z.cloudfront.net/downloads/connect/"
        f"latest/bin/ibm-aspera-connect_{version}_{plat}_{arch}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    installer_script = f"ibm-aspera-connect_{version}_{plat}_{arch}.sh"
    subprocess.run(
        [f"./{installer_script}"],
        check=True,
    )
    if not os.path.isdir(script_target):
        msg = f"Aspera install target not found: {script_target}"
        raise RuntimeError(msg)
    if prefix != script_target:
        cp(script_target, prefix, recursive=True)
        rm(script_target)
        rm(aspera_user_prefix)
    ascp = os.path.join(prefix, "bin", "ascp")
    if not os.path.isfile(ascp):
        msg = f"ascp not found at: {ascp}"
        raise RuntimeError(msg)
