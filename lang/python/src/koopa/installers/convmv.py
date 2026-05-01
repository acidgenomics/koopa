"""Install convmv."""

from __future__ import annotations

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
    """Install convmv."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://www.j3e.de/linux/convmv/convmv-{version}.tar.gz"
    download_extract_cd(url)
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=env.to_env_dict(),
        check=True,
    )
