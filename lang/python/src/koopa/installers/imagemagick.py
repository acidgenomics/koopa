"""Install imagemagick."""

from __future__ import annotations

import sys

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install imagemagick."""
    env = activate_app("pkg-config", build_only=True)
    deps = [
        "zlib",
        "zstd",
        "xz",
        "freetype",
        "jpeg",
        "libde265",
        "libheif",
        "libpng",
        "libtiff",
        "libtool",
        "icu4c",
        "libxml2",
        "libzip",
        "fontconfig",
    ]
    if sys.platform != "darwin":
        deps.append("bzip2")
    env = activate_app(*deps, env=env)
    url = f"https://imagemagick.org/archive/releases/ImageMagick-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-static",
            "--with-heic=yes",
            "--with-modules",
            f"--prefix={prefix}",
        ],
        env=env,
    )
