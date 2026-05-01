"""Install cairo."""

from __future__ import annotations

import sys

from koopa.build import activate_app, meson_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install cairo."""
    env = activate_app("meson", "ninja", "pkg-config", build_only=True)
    deps = [
        "zlib",
        "gettext",
        "freetype",
        "icu4c",
        "libxml2",
        "fontconfig",
        "libffi",
        "pcre2",
        "glib",
        "libpng",
        "pixman",
        "expat",
    ]
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
            ]
        )
    env = activate_app(*deps, env=env)
    url = f"https://cairographics.org/releases/cairo-{version}.tar.xz"
    download_extract_cd(url)
    meson_args = [
        "-Dfontconfig=enabled",
        "-Dfreetype=enabled",
        "-Dglib=enabled",
        "-Dpng=enabled",
        "-Dzlib=enabled",
    ]
    if sys.platform == "darwin":
        meson_args.append("-Dquartz=disabled")
    else:
        meson_args.extend(
            [
                "-Dxcb=enabled",
                "-Dxlib-xcb=enabled",
                "-Dxlib=enabled",
            ]
        )
    meson_build(prefix=prefix, args=meson_args, env=env)
