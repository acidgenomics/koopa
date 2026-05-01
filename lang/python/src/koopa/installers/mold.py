"""Install mold."""

from __future__ import annotations

import sys

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install mold."""
    env = activate_app("mimalloc", "tbb", "zlib", "zstd", env=None)
    url = f"https://github.com/rui314/mold/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    jobs = 1 if sys.platform != "darwin" else None
    cmake_build(
        prefix=prefix,
        args=[
            "-DCMAKE_SKIP_INSTALL_RULES=OFF",
            "-DMOLD_LTO=ON",
            "-DMOLD_USE_MIMALLOC=ON",
            "-DMOLD_USE_SYSTEM_MIMALLOC=ON",
            "-DMOLD_USE_SYSTEM_TBB=ON",
        ],
        jobs=jobs,
        env=env,
    )
