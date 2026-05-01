"""Install less."""

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
    """Install less."""
    env = activate_app("autoconf", "groff", build_only=True)
    env = activate_app("ncurses", "pcre2", env=env)
    url = (
        f"https://github.com/gwsw/less/archive/"
        f"refs/tags/v{version}-rel.tar.gz"
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess.run(
        ["make", "-f", "Makefile.aut", "distfiles"],
        env=subprocess_env,
        check=True,
    )
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            "--with-regex=pcre2",
        ],
        env=env,
    )
