"""Install libgeotiff."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libgeotiff."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app(
        "zlib", "zstd", "openssl", "libssh2", "curl",
        "libjpeg-turbo", "libtiff", "sqlite", "proj",
        env=env,
    )
    proj_prefix = app_prefix("proj")
    libtiff_prefix = app_prefix("libtiff")
    url = (
        f"https://download.osgeo.org/geotiff/libgeotiff/"
        f"libgeotiff-{version}.tar.gz"
    )
    download_extract_cd(url)
    conf_args = [
        f"--prefix={prefix}",
        "--disable-static",
        "--enable-shared",
        "--with-jpeg",
        f"--with-libtiff={libtiff_prefix}",
        f"--with-proj={proj_prefix}",
    ]
    make_build(conf_args=conf_args, env=env)
