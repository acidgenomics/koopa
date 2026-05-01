"""Install xxhash."""

from __future__ import annotations

import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xxhash."""
    env = activate_app("make", "pkg-config", build_only=True)
    make = locate("make")
    url = f"https://github.com/Cyan4973/xxHash/archive/v{version}.tar.gz"
    download_extract_cd(url)
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=env.to_env_dict(),
        check=True,
    )
    remove_static_libs(prefix)
