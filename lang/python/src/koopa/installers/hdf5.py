"""Install hdf5."""

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
    """Install hdf5."""
    env = activate_app("libaec", "zlib", env=None)
    libaec_prefix = app_prefix("libaec")
    zlib_prefix = app_prefix("zlib")
    ext = shared_ext()
    url = (
        f"https://github.com/HDFGroup/hdf5/releases/download/"
        f"{version}/hdf5-{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DHDF5_BUILD_CPP_LIB:BOOL=ON",
            "-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON",
            "-DHDF5_INSTALL_CMAKE_DIR=lib/cmake/hdf5",
            "-DHDF5_USE_GNU_DIRS:BOOL=ON",
            f"-DSZIP_INCLUDE_DIR={libaec_prefix}/include",
            f"-DSZIP_LIBRARY={libaec_prefix}/lib/libsz.{ext}",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        ],
        env=env,
    )
