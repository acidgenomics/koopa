"""Install nlohmann-json."""

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
    """Install nlohmann-json."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://github.com/nlohmann/json/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DJSON_BuildTests=OFF", "-DJSON_MultipleHeaders=ON"],
        env=env,
    )
