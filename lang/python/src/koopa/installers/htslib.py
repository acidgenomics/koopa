"""Install htslib."""

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
    """Install htslib."""
    deps = ["curl", "libdeflate", "openssl", "xz", "zlib"]
    if sys.platform != "darwin":
        deps.append("bzip2")
    env = activate_app(*deps, env=None)
    url = (
        f"https://github.com/samtools/htslib/releases/download/"
        f"{version}/htslib-{version}.tar.bz2"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--enable-gcs",
            "--enable-libcurl",
            "--enable-plugins",
            "--enable-s3",
            f"--prefix={prefix}",
            "--with-libdeflate",
        ],
        env=env,
    )
