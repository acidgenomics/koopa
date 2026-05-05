"""Install tree-sitter."""

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
    download_extract_cd()
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
