"""Install libsolv."""

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
    """Install libsolv."""
    env = activate_app("zlib", env=None)
    zlib_prefix = app_prefix("zlib")
    ext = shared_ext()
    url = (
        f"https://github.com/openSUSE/libsolv/archive/"
        f"refs/tags/{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DENABLE_CONDA=yes",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={os.path.join(zlib_prefix, 'lib', f'libz.{ext}')}",
        ],
        env=env,
    )
