"""Install libuv."""

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
    """Install libuv."""
    env = activate_app("autoconf", "automake", "libtool", "m4", "pkg-config", build_only=True)
    url = f"https://github.com/libuv/libuv/archive/v{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess.run(["./autogen.sh"], env=subprocess_env, check=True)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
