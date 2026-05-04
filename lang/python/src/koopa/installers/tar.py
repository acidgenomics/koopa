"""Install tar."""

from __future__ import annotations

import os
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
    """Install tar."""
    env = activate_app("make", build_only=True)
    for url in [
        f"https://mirrors.kernel.org/gnu/tar/tar-{version}.tar.gz",
        f"https://ftpmirror.gnu.org/gnu/tar/tar-{version}.tar.gz",
        f"https://ftp.gnu.org/gnu/tar/tar-{version}.tar.gz",
    ]:
        tarball = download(url)
        if is_valid_archive(tarball):
            break
    extract(tarball, "src")
    os.chdir("src")
    os.environ["FORCE_UNSAFE_CONFIGURE"] = "1"
    conf_args = [
        "--disable-nls",
        "--program-prefix=g",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("LIBS=-liconv")
    make_build(conf_args=conf_args, env=env)
