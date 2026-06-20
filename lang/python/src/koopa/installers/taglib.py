"""Install taglib."""

import subprocess

from koopa.build import app_prefix, cmake_build, shared_ext
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install taglib."""
    env = activate_app_deps()
    zlib_prefix = app_prefix("zlib")
    ext = shared_ext()
    download_extract_cd()
    subprocess.run(
        ["git", "submodule", "update", "--init"],
        check=True,
    )
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_SHARED_LIBS=ON",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        ],
        env=env,
    )
