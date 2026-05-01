"""Install reproc."""

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
    """Install reproc."""
    env = activate_app("pkg-config", build_only=True)
    url = (
        f"https://github.com/DaanDeMeyer/reproc/archive/"
        f"refs/tags/v{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DBUILD_SHARED_LIBS=ON", "-DREPROC++=ON"],
        env=env,
    )
