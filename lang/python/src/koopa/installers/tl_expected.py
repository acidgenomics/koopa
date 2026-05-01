"""Install tl-expected."""

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
    """Install tl-expected."""
    url = f"https://github.com/TartanLlama/expected/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DEXPECTED_ENABLE_TESTS=OFF"],
    )
