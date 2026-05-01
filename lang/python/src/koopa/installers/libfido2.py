"""Install libfido2."""

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
    """Install libfido2."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libcbor", "openssl", "zlib", env=env)
    url = f"https://github.com/Yubico/libfido2/archive/{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DBUILD_STATIC_LIBS=OFF"],
        env=env,
    )
