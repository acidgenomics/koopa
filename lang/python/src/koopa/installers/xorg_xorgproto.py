"""Install xorg-xorgproto."""

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
    """Install xorg-xorgproto."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://xorg.freedesktop.org/archive/individual/proto/xorgproto-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            f"--prefix={prefix}",
        ],
        env=env,
    )
