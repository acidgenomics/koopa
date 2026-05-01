"""Install c-ares."""

from __future__ import annotations

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install c-ares."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://github.com/c-ares/c-ares/releases/download/v{version}/c-ares-{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(prefix=prefix, env=env)
