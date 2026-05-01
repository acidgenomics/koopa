"""Install libtermkey."""

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
    """Install libtermkey."""
    env = activate_app("libtool", "make", "pkg-config", build_only=True)
    env = activate_app("ncurses", "unibilium", env=env)
    make = locate("make")
    url = f"https://www.leonerd.org.uk/code/libtermkey/libtermkey-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess.run(
        [make, f"PREFIX={prefix}"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=subprocess_env,
        check=True,
    )
