"""Install luarocks."""

import subprocess

from koopa.build import locate, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install luarocks.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    env = activate_app_deps()
    lua = locate("lua")
    result = subprocess.run(
        [lua, "-v"],
        capture_output=True,
        text=True,
        check=False,
    )
    lua_ver_str = result.stdout.strip() or result.stderr.strip()
    parts = lua_ver_str.split()
    lua_ver = "5.4"
    for p in parts:
        if p[0].isdigit():
            lua_ver = major_minor_version(p)
            break
    download_extract_cd()
    conf_args = [
        f"--prefix={prefix}",
        f"--lua-version={lua_ver}",
    ]
    make_build(conf_args=conf_args, env=env)
