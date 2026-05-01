"""Install armadillo."""

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
    """Install armadillo."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "hdf5", env=env)
    url = f"https://koopa.acidgenomics.com/src/armadillo/{version}.tar.xz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DALLOW_OPENBLAS_MACOS=ON"],
        env=env,
    )
