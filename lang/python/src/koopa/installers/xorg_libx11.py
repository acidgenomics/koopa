"""Install xorg-libx11."""

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
    """Install xorg-libx11."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app(
        "xorg-xorgproto",
        "xorg-xtrans",
        "xorg-libpthread-stubs",
        "xorg-libxau",
        "xorg-libxdmcp",
        "xorg-libxcb",
        env=env,
    )
    url = f"https://xorg.freedesktop.org/archive/individual/lib/libX11-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-silent-rules",
            "--disable-static",
            "--enable-ipv6",
            "--enable-loadable-i18n",
            "--enable-specs=no",
            "--enable-tcp-transport",
            "--enable-unix-transport",
            "--enable-xthreads",
            f"--prefix={prefix}",
        ],
        env=env,
    )
