"""Install duckdb."""

from __future__ import annotations

import subprocess

from koopa.build import activate_app, cmake_build


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install duckdb."""
    env = activate_app("python", build_only=True)
    subprocess.run(
        [
            "git",
            "clone",
            "--depth=1",
            f"--branch=v{version}",
            "https://github.com/duckdb/duckdb.git",
            "src",
        ],
        check=True,
    )
    import os

    os.chdir("src")
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_EXTENSIONS=autocomplete;icu;parquet;json",
            "-DENABLE_EXTENSION_AUTOINSTALL=ON",
            "-DENABLE_EXTENSION_AUTOLOADING=ON",
        ],
        env=env,
    )
