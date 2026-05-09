"""Install libarchive."""

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
    """Install libarchive."""
    env = activate_app("pkg-config", build_only=True)
    deps = ["expat", "lz4", "xz", "zlib", "zstd"]
    if sys.platform != "darwin":
        deps.append("bzip2")
    env = activate_app(*deps, env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-static",
            "--without-lzma",
            "--without-lzo2",
            "--without-nettle",
            "--without-openssl",
            "--without-xml2",
            f"--prefix={prefix}",
        ],
        env=env,
    )
