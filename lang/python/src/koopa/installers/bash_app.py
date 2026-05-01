"""Install bash."""

from __future__ import annotations

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
    gnu_mirror = "https://ftpmirror.gnu.org"
    url = f"{gnu_mirror}/bash/bash-{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [f"--prefix={prefix}"]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = f"-DSSH_SOURCE_BASHRC {cflags}".strip()
    if platform.machine() == "aarch64" and os.path.isfile("/etc/alpine-release"):
        conf_args.append("--without-bash-malloc")
    make_build(conf_args=conf_args, env=env)
