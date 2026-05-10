"""Install apache-arrow."""

import os
import platform

from koopa.build import cmake_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install apache-arrow."""
    env = activate_app_deps()
    download_extract_cd()
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
