"""Install googletest."""

from __future__ import annotations

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install googletest."""
    env = activate_app("pkg-config", build_only=True)
    url = (
        f"https://github.com/google/googletest/archive/"
        f"refs/tags/v{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DBUILD_GMOCK=ON", "-DBUILD_SHARED_LIBS=ON"],
        env=env,
    )
