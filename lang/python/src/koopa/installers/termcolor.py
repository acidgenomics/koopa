"""Install termcolor."""

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
    """Install termcolor."""
    url = f"https://github.com/ikalnytskyi/termcolor/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(prefix=prefix)
