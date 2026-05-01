"""Install libzip."""

from __future__ import annotations

import sys

from koopa.build import activate_app, app_prefix, cmake_build, shared_ext
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libzip."""
    env = activate_app("pkg-config", "perl", build_only=True)
    deps = ["zlib", "zstd", "nettle", "openssl"]
    if sys.platform != "darwin":
        deps.append("bzip2")
    env = activate_app(*deps, env=env)
    zlib_prefix = app_prefix("zlib")
    zstd_prefix = app_prefix("zstd")
    openssl_prefix = app_prefix("openssl")
    ext = shared_ext()
    url = (
        f"https://github.com/nih-at/libzip/releases/download/"
        f"v{version}/libzip-{version}.tar.xz"
    )
    download_extract_cd(url)
    cmake_args = [
        "-DENABLE_BZIP2=ON",
        "-DENABLE_ZSTD=ON",
        f"-DOPENSSL_CRYPTO_LIBRARY={openssl_prefix}/lib/libcrypto.{ext}",
        f"-DOPENSSL_INCLUDE_DIR={openssl_prefix}/include",
        f"-DOPENSSL_SSL_LIBRARY={openssl_prefix}/lib/libssl.{ext}",
        f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
        f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        f"-DZstd_INCLUDE_DIR={zstd_prefix}/include",
        f"-DZstd_LIBRARY={zstd_prefix}/lib/libzstd.{ext}",
    ]
    if sys.platform != "darwin":
        bzip2_prefix = app_prefix("bzip2")
        cmake_args.extend([
            f"-DBZIP2_INCLUDE_DIR={bzip2_prefix}/include",
            f"-DBZIP2_LIBRARY_RELEASE={bzip2_prefix}/lib/libbz2.{ext}",
        ])
    cmake_build(prefix=prefix, args=cmake_args, env=env)
