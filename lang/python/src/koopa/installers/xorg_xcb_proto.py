"""Install xorg-xcb-proto."""

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
    """Install xorg-xcb-proto."""
    env = activate_app("pkg-config", "python", build_only=True)
    python = locate("python3")
    url = f"https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-silent-rules",
            f"--prefix={prefix}",
            f"PYTHON={python}",
        ],
        env=env,
    )
