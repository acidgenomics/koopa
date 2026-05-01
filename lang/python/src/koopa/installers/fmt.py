"""Install fmt."""

from __future__ import annotations

from koopa.build import cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install fmt."""
    url = f"https://github.com/fmtlib/fmt/archive/refs/tags/{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_SHARED_LIBS=ON",
            "-DFMT_DOC=OFF",
            "-DFMT_INSTALL=ON",
            "-DFMT_TEST=ON",
        ],
    )
