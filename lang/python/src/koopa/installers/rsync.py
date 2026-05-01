"""Install rsync."""

from __future__ import annotations

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
    """Install rsync."""
    env = activate_app("zlib", "zstd", "lz4", "openssl", "xxhash", env=None)
    url = f"https://www.mirrorservice.org/sites/rsync.samba.org/rsync-{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [
        "--disable-debug",
        "--enable-ipv6",
        "--enable-lz4",
        "--enable-openssl",
        "--enable-xxhash",
        "--with-included-popt=no",
        "--with-included-zlib=no",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("--disable-zstd")
    else:
        conf_args.append("--enable-zstd")
    make_build(conf_args=conf_args, env=env)
