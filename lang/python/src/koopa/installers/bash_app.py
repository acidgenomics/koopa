"""Install bash."""

from __future__ import annotations

import os
import platform
import sys

from koopa.archive import extract, is_valid_archive
from koopa.build import activate_app, make_build
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bash."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://mirrors.kernel.org/gnu/bash/bash-{version}.tar.gz"
    tarball = download(url)
    if not is_valid_archive(tarball):
        url = f"https://ftp.gnu.org/gnu/bash/bash-{version}.tar.gz"
        tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    conf_args = [f"--prefix={prefix}"]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = f"-DSSH_SOURCE_BASHRC {cflags}".strip()
    if platform.machine() == "aarch64" and os.path.isfile("/etc/alpine-release"):
        conf_args.append("--without-bash-malloc")
    make_build(conf_args=conf_args, env=env)
