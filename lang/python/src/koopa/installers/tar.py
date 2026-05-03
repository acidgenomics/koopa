"""Install tar."""

from __future__ import annotations

import os
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
    """Install tar."""
    env = activate_app("make", build_only=True)
    url = f"https://ftpmirror.gnu.org/gnu/tar/tar-{version}.tar.gz"
    download_extract_cd(url)
    os.environ["FORCE_UNSAFE_CONFIGURE"] = "1"
    conf_args = [
        "--program-prefix=g",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("LIBS=-liconv")
    make_build(conf_args=conf_args, env=env)
