"""Install neofetch."""

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
    """Install neofetch."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://github.com/dylanaraps/neofetch/archive/{version}.tar.gz"
    download_extract_cd(url)
    subprocess.run(
        [make, f"PREFIX={prefix}", "install"],
        env=env.to_env_dict(),
        check=True,
    )
