"""Install proj."""

from koopa.build import (
    app_prefix,
    cmake_build,
    shared_ext,
)
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install proj."""
    env = activate_app_deps()
    sqlite_prefix = app_prefix("sqlite")
    curl_prefix = app_prefix("curl")
    libtiff_prefix = app_prefix("libtiff")
    ext = shared_ext()
    download_extract_cd()
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
