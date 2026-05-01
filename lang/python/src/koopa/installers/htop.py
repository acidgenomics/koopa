"""Install htop."""

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
    """Install htop."""
    env = activate_app("autoconf", "automake", build_only=True)
    env = activate_app("ncurses", env=env)
    url = f"https://github.com/htop-dev/htop/archive/{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess.run(["./autogen.sh"], env=subprocess_env, check=True)
    make_build(
        conf_args=[
            "--disable-unicode",
            f"--prefix={prefix}",
        ],
        env=env,
    )
