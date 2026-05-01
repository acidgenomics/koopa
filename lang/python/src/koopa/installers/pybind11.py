"""Install pybind11."""

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
    """Install pybind11."""
    env = activate_app("python", build_only=True)
    url = f"https://github.com/pybind/pybind11/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DPYBIND11_NOPYTHON=ON", "-DPYBIND11_TEST=OFF"],
        env=env,
    )
