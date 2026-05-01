"""Install xorg-libxcb."""

from __future__ import annotations

from koopa.build import activate_app, locate, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xorg-libxcb."""
    env = activate_app("pkg-config", "python", build_only=True)
    env = activate_app(
        "xorg-xorgproto",
        "xorg-xcb-proto",
        "xorg-libpthread-stubs",
        "xorg-libxau",
        "xorg-libxdmcp",
        env=env,
    )
    python = locate("python3")
    url = (
        f"https://xorg.freedesktop.org/archive/individual/lib/"
        f"libxcb-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-devel-docs=no",
            "--enable-dri3",
            "--enable-ge",
            "--enable-selinux",
            "--enable-xevie",
            "--enable-xprint",
            f"--prefix={prefix}",
            "--with-doxygen=no",
            f"PYTHON={python}",
        ],
        env=env,
    )
