"""Install r-gfortran."""

from __future__ import annotations

import subprocess

from koopa.download import download
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r-gfortran."""
    machine = arch()
    if machine == "aarch64":
        machine = "arm64"
    url = f"https://mac.r-project.org/tools/gfortran-{version}-{machine}-big-sur.pkg"
    pkg_file = download(url)
    subprocess.run(
        ["sudo", "installer", "-pkg", pkg_file, "-target", "/"],
        check=True,
    )
