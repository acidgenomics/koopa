"""Install tree-sitter."""

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
    """Install tree-sitter."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess.run(
        [make, "AMALGAMATED=1"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=subprocess_env,
        check=True,
    )
