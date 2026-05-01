"""Install zstd."""

from __future__ import annotations

import os

from koopa.build import activate_app, app_prefix, cmake_build, shared_ext
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install zstd."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("lz4", "zlib", env=env)
    lz4_prefix = app_prefix("lz4")
    zlib_prefix = app_prefix("zlib")
    ext = shared_ext()
    url = f"https://github.com/facebook/zstd/archive/v{version}.tar.gz"
    download_extract_cd(url)
    os.chdir("build/cmake")
    cmake_build(
        prefix=prefix,
        args=[
            "-DCMAKE_CXX_STANDARD=11",
            "-DZSTD_BUILD_CONTRIB=ON",
            "-DZSTD_BUILD_STATIC=OFF",
            "-DZSTD_LEGACY_SUPPORT=ON",
            "-DZSTD_LZ4_SUPPORT=ON",
            "-DZSTD_LZMA_SUPPORT=OFF",
            "-DZSTD_PROGRAMS_LINK_SHARED=ON",
            "-DZSTD_ZLIB_SUPPORT=ON",
            f"-DLIBLZ4_INCLUDE_DIR={lz4_prefix}/include",
            f"-DLIBLZ4_LIBRARY={lz4_prefix}/lib/liblz4.{ext}",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        ],
        env=env,
    )
