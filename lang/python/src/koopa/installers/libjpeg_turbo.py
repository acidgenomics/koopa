"""Install libjpeg-turbo."""

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
    """Install libjpeg-turbo."""
    env = activate_app("pkg-config", build_only=True)
    url = (
        f"https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/"
        f"{version}/libjpeg-turbo-{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DENABLE_STATIC=OFF", "-DWITH_JPEG8=ON"],
        env=env,
    )
