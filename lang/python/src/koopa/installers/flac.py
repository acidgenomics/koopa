"""Install flac."""

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
    """Install flac."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://downloads.xiph.org/releases/flac/flac-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=["--disable-thorough-tests", f"--prefix={prefix}"],
        env=env,
    )
