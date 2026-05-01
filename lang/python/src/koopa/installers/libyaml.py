"""Install libyaml."""

from __future__ import annotations

import subprocess

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libyaml."""
    env = activate_app(
        "autoconf", "automake", "libtool", "m4", "pkg-config",
        build_only=True,
    )
    libtool_prefix = app_prefix("libtool")
    url = f"https://github.com/yaml/libyaml/archive/{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess_env["ACLOCAL_PATH"] = f"{libtool_prefix}/share/aclocal"
    subprocess.run(["autoupdate"], env=subprocess_env, check=True)
    subprocess.run(
        ["autoreconf", "--force", "--install", "--verbose"],
        env=subprocess_env,
        check=True,
    )
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
