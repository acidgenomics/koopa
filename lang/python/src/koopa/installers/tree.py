"""Install tree."""

from __future__ import annotations

import os
import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tree."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = (
        f"https://github.com/Old-Man-Programmer/tree/archive/"
        f"refs/tags/{version}.tar.gz"
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess.run(
        [make, "CFLAGS=-O2"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            "install",
            f"PREFIX={prefix}",
            f"MANDIR={os.path.join(prefix, 'share', 'man')}",
        ],
        env=subprocess_env,
        check=True,
    )
