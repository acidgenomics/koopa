"""Install rsync."""

import sys

from koopa.build import activate_app, make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import download_extract_cd, extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
    use_mirror: bool = False,
) -> None:
    """Install rsync."""
    env = activate_app("zlib", "zstd", "lz4", "openssl", "xxhash", env=None)
    filename = f"rsync-{version}.tar.gz"
    primary_url = f"https://www.mirrorservice.org/sites/rsync.samba.org/{filename}"
    koopa_name = "rsync"
    if use_mirror:
        tarball = download_with_mirror(primary_url, koopa_name, filename)
        extract_cd(tarball)
    else:
        download_extract_cd(primary_url)
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
