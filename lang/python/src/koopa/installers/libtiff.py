"""Install libtiff."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libtiff."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libjpeg-turbo", "zstd", env=env)
    url = f"https://download.osgeo.org/libtiff/tiff-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-lzma",
            "--disable-static",
            "--disable-webp",
            "--enable-shared=yes",
            "--without-x",
            f"--prefix={prefix}",
        ],
        env=env,
    )
