"""Install xorg-libxrandr."""

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
    """Install xorg-libxrandr."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app(
        "xorg-xorgproto",
        "xorg-libpthread-stubs",
        "xorg-libxau",
        "xorg-libxdmcp",
        "xorg-libxcb",
        "xorg-libx11",
        "xorg-libxext",
        "xorg-libxrender",
        env=env,
    )
    url = (
        f"https://xorg.freedesktop.org/archive/individual/lib/"
        f"libXrandr-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
