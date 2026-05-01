"""Install libgit2."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, cmake_build, shared_ext
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libgit2."""
    env = activate_app("zlib", "pcre", "openssl", "libssh2", env=None)
    zlib_prefix = app_prefix("zlib")
    pcre_prefix = app_prefix("pcre")
    openssl_prefix = app_prefix("openssl")
    libssh2_prefix = app_prefix("libssh2")
    ext = shared_ext()
    url = f"https://github.com/libgit2/libgit2/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_TESTS=OFF",
            "-DUSE_HTTPS=ON",
            "-DUSE_SSH=ON",
            f"-DLIBSSH2_INCLUDE_DIR={libssh2_prefix}/include",
            f"-DLIBSSH2_LIBRARY={libssh2_prefix}/lib/libssh2.{ext}",
            f"-DOPENSSL_CRYPTO_LIBRARY={openssl_prefix}/lib/libcrypto.{ext}",
            f"-DOPENSSL_INCLUDE_DIR={openssl_prefix}/include",
            f"-DOPENSSL_SSL_LIBRARY={openssl_prefix}/lib/libssl.{ext}",
            f"-DPCRE_INCLUDE_DIR={pcre_prefix}/include",
            f"-DPCRE_LIBRARY={pcre_prefix}/lib/libpcre.{ext}",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        ],
        env=env,
    )
