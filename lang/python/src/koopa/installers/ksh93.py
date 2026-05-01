"""Install ksh93."""

from __future__ import annotations

import subprocess

from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ksh93."""
    url = f"https://github.com/ksh93/ksh/archive/v{version}.tar.gz"
    download_extract_cd(url)
    subprocess.run(
        ["bin/package", "make", "VERBOSE=1"],
        check=True,
    )
    subprocess.run(
        ["bin/package", "install", prefix],
        check=True,
    )
