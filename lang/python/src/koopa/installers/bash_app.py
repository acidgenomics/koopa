"""Install bash."""

import os
import platform
import sys

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bash."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("ncurses", "readline", env=env)
    download_extract_cd()
    conf_args = [
        f"--prefix={prefix}",
        "--with-curses",
        "--with-installed-readline",
    ]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = f"-DSSH_SOURCE_BASHRC {cflags}".strip()
    if platform.machine() == "aarch64" and os.path.isfile("/etc/alpine-release"):
        conf_args.append("--without-bash-malloc")
    make_build(conf_args=conf_args, env=env)
