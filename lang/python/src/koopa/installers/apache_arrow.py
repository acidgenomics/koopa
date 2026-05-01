"""Install apache-arrow."""

from __future__ import annotations

import os
import platform

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install apache-arrow."""
    env = activate_app("pkg-config", "python", build_only=True)
    env = activate_app("boost", "openssl", "curl", env=env)
    url = (
        f"https://archive.apache.org/dist/arrow/arrow-{version}/"
        f"apache-arrow-{version}.tar.gz"
    )
    download_extract_cd(url)
    os.chdir("cpp")
    cmake_args = [
        "-DARROW_CSV=ON",
        "-DARROW_DEPENDENCY_SOURCE=BUNDLED",
        "-DARROW_PARQUET=ON",
        "-DARROW_WITH_BZ2=ON",
        "-DARROW_WITH_LZ4=ON",
        "-DARROW_WITH_SNAPPY=ON",
        "-DARROW_WITH_ZLIB=ON",
        "-DARROW_WITH_ZSTD=ON",
    ]
    machine = platform.machine()
    if machine not in ("aarch64", "arm64"):
        cmake_args.append("-DARROW_MIMALLOC=ON")
    cmake_build(prefix=prefix, args=cmake_args, env=env)
