"""Install openjpeg."""

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
    """Install openjpeg."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app(
        "zlib", "zstd", "libjpeg-turbo", "libpng", "libtiff", env=env
    )
    zlib_prefix = app_prefix("zlib")
    libpng_prefix = app_prefix("libpng")
    libtiff_prefix = app_prefix("libtiff")
    ext = shared_ext()
    url = f"https://github.com/uclouvl/openjpeg/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_DOC=OFF",
            "-DBUILD_SHARED_LIBS=ON",
            "-DBUILD_STATIC_LIBS=OFF",
            f"-DPNG_INCLUDE_DIR={libpng_prefix}/include",
            f"-DPNG_LIBRARY={libpng_prefix}/lib/libpng.{ext}",
            f"-DTIFF_INCLUDE_DIR={libtiff_prefix}/include",
            f"-DTIFF_LIBRARY={libtiff_prefix}/lib/libtiff.{ext}",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        ],
        env=env,
    )
