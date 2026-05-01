"""Install vim."""

from __future__ import annotations

import sys

from koopa.build import activate_app, locate, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install vim."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("ncurses", "python", env=env)
    python = locate("python3")
    url = f"https://github.com/vim/vim/archive/v{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [
        "--enable-huge",
        "--enable-multibyte",
        "--enable-python3interp",
        "--enable-terminal",
        f"--with-python3-command={python}",
        "--with-tlib=ncurses",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.extend(
            [
                "--disable-gui",
                "--without-x",
            ]
        )
    make_build(conf_args=conf_args, env=env)
