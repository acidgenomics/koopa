"""Install fltk."""

from __future__ import annotations

import sys

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install fltk."""
    env = activate_app("pkg-config", build_only=True)
    deps = ["zlib", "libjpeg-turbo", "libpng", "freetype"]
    if sys.platform != "darwin":
        deps.extend(
            [
                "xorg-xorgproto",
                "xorg-xcb-proto",
                "xorg-libpthread-stubs",
                "xorg-libxau",
                "xorg-libxdmcp",
                "xorg-libxcb",
                "xorg-libx11",
                "xorg-libxext",
                "xorg-libxrender",
                "xorg-libxrandr",
            ]
        )
    env = activate_app(*deps, env=env)
    url = f"https://github.com/fltk/fltk/releases/download/release-{version}/fltk-{version}-source.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DFLTK_BUILD_FLUID=ON",
            "-DFLTK_BUILD_SHARED_LIBS=ON",
            "-DFLTK_BUILD_TEST=OFF",
            "-DOPTION_USE_PANGO=OFF",
            "-DOPTION_USE_THREADS=ON",
        ],
        env=env,
    )
    remove_static_libs(prefix)
