"""Install autodock-adfr."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install autodock-adfr."""
    if sys.platform == "darwin":
        platform = "Darwin"
    else:
        platform = "Linux"
    url = (
        f"https://ccsb.scripps.edu/adfr/download/"
        f"ADFRsuite_{version}_{platform}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    libexec = os.path.join(prefix, "libexec")
    os.makedirs(libexec, exist_ok=True)
    subprocess.run(
        [
            "bash", "-c",
            f"yes | ./install.sh -d {libexec} -c 0",
        ],
        check=True,
    )
    ln(os.path.join(libexec, "bin"), os.path.join(prefix, "bin"))
