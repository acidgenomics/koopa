"""Install proj."""

from __future__ import annotations

from koopa.build import (
    activate_app,
    app_prefix,
    cmake_build,
    shared_ext,
)
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install proj."""
    env = activate_app("pkg-config", "python", build_only=True)
    env = activate_app(
        "zlib",
        "zstd",
        "openssl",
        "libssh2",
        "curl",
        "libjpeg-turbo",
        "libtiff",
        "sqlite",
        env=env,
    )
    sqlite_prefix = app_prefix("sqlite")
    curl_prefix = app_prefix("curl")
    libtiff_prefix = app_prefix("libtiff")
    ext = shared_ext()
    url = f"https://download.osgeo.org/proj/proj-{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            f"-DCURL_INCLUDE_DIR={curl_prefix}/include",
            f"-DCURL_LIBRARY={curl_prefix}/lib/libcurl.{ext}",
            "-DENABLE_CURL=ON",
            "-DENABLE_TIFF=ON",
            f"-DSQLite3_INCLUDE_DIR={sqlite_prefix}/include",
            f"-DSQLite3_LIBRARY={sqlite_prefix}/lib/libsqlite3.{ext}",
            f"-DTIFF_INCLUDE_DIR={libtiff_prefix}/include",
            f"-DTIFF_LIBRARY={libtiff_prefix}/lib/libtiff.{ext}",
        ],
        env=env,
    )
