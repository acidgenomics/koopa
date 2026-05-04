"""Install screen."""

from __future__ import annotations

import subprocess

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install screen."""
    env = activate_app("autoconf", "automake", build_only=True)
    env = activate_app("libxcrypt", "ncurses", env=env)
    url = f"https://mirrors.kernel.org/gnu/screen/screen-{version}.tar.gz"
    download_extract_cd(url)
    subprocess.run(
        ["./autogen.sh"],
        env=env.to_env_dict(),
        check=True,
    )
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
