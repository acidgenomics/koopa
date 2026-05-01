"""Install xorg-libice."""

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
    """Install xorg-libice."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("xorg-xorgproto", "xorg-xtrans", env=env)
    url = (
        f"https://xorg.freedesktop.org/archive/individual/lib/"
        f"libICE-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-docs=no",
            "--enable-specs=no",
            f"--prefix={prefix}",
        ],
        env=env,
    )
