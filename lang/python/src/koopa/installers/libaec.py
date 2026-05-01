"""Install libaec."""

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
    """Install libaec."""
    env = activate_app("pkg-config", build_only=True)
    url = (
        f"https://gitlab.dkrz.de/k202009/libaec/-/archive/"
        f"v{version}/libaec-v{version}.tar.gz"
    )
    download_extract_cd(url)
    cmake_build(prefix=prefix, env=env)
