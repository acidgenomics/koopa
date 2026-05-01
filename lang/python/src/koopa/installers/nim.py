"""Install nim."""

from __future__ import annotations

import os
import subprocess

from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nim."""
    url = f"https://nim-lang.org/download/nim-{version}.tar.xz"
    download_extract_cd(url)
    subprocess.run(["sh", "build.sh"], check=True)
    subprocess.run(
        ["bin/nim", "c", "-d:release", "koch"],
        check=True,
    )
    subprocess.run(
        ["./koch", "boot", "-d:release"],
        check=True,
    )
    subprocess.run(
        ["./koch", "tools"],
        check=True,
    )
    subprocess.run(
        ["sh", "install.sh", prefix],
        check=True,
    )
