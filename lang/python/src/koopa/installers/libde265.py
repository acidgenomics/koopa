"""Install libde265."""

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
    """Install libde265."""
    url = (
        f"https://github.com/strukturag/libde265/releases/download/"
        f"v{version}/libde265-{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DENABLE_DECODER=OFF", "-DENABLE_TOOLS=ON"],
    )
