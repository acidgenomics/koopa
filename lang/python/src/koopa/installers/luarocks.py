"""Install luarocks."""

from __future__ import annotations

import subprocess

from koopa.build import activate_app, locate, make_build
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install luarocks."""
    env = activate_app("make", build_only=True)
    env = activate_app("lua", env=env)
    lua = locate("lua")
    result = subprocess.run(
        [lua, "-v"],
        capture_output=True,
        text=True,
    )
    lua_ver_str = result.stdout.strip() or result.stderr.strip()
    parts = lua_ver_str.split()
    lua_ver = "5.4"
    for p in parts:
        if p[0].isdigit():
            lua_ver = major_minor_version(p)
            break
    url = f"https://luarocks.org/releases/luarocks-{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [
        f"--prefix={prefix}",
        f"--lua-version={lua_ver}",
    ]
    make_build(conf_args=conf_args, env=env)
