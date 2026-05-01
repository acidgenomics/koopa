"""Install spdlog."""

from __future__ import annotations

import os

from koopa.build import activate_app, app_prefix, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install spdlog."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("fmt", env=env)
    fmt_prefix = app_prefix("fmt")
    fmt_cmake = os.path.join(fmt_prefix, "lib", "cmake", "fmt")
    url = f"https://github.com/gabime/spdlog/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DSPDLOG_BUILD_BENCH=OFF",
            "-DSPDLOG_BUILD_SHARED=ON",
            "-DSPDLOG_BUILD_TESTS=OFF",
            "-DSPDLOG_FMT_EXTERNAL=ON",
            f"-Dfmt_DIR={fmt_cmake}",
        ],
        env=env,
    )
