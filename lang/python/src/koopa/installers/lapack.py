"""Install lapack."""

from __future__ import annotations

import shutil

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install lapack."""
    env = activate_app("pkg-config", build_only=True)
    gfortran = shutil.which("gfortran")
    if gfortran is None:
        msg = "gfortran not found."
        raise FileNotFoundError(msg)
    url = f"https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_SHARED_LIBS=ON",
            "-DLAPACKE=ON",
            f"-DCMAKE_Fortran_COMPILER={gfortran}",
        ],
        env=env,
    )
