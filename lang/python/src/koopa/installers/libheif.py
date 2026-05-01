"""Install libheif."""

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
    """Install libheif."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "libde265", "libjpeg-turbo", "libpng", env=env)
    libjpeg_prefix = app_prefix("libjpeg-turbo")
    libpng_prefix = app_prefix("libpng")
    ext = shared_ext()
    url = f"https://github.com/nicolo-ribaudo/libheif/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_TESTING=OFF",
            f"-DJPEG_INCLUDE_DIR={libjpeg_prefix}/include",
            f"-DJPEG_LIBRARY={libjpeg_prefix}/lib/libjpeg.{ext}",
            f"-DPNG_INCLUDE_DIR={libpng_prefix}/include",
            f"-DPNG_LIBRARY={libpng_prefix}/lib/libpng.{ext}",
        ],
        env=env,
    )
