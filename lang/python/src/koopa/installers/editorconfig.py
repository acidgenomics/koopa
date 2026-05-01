"""Install editorconfig."""

from __future__ import annotations

import os

from koopa.build import activate_app, app_prefix, cmake_build, shared_ext
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install editorconfig."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("pcre2", env=env)
    pcre2_prefix = app_prefix("pcre2")
    pcre2_lib = os.path.join(pcre2_prefix, "lib")
    pcre2_include = os.path.join(pcre2_prefix, "include")
    ext = shared_ext()
    url = f"https://github.com/editorconfig/editorconfig-core-c/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            f"-DCMAKE_LIBRARY_PATH={pcre2_lib}",
            f"-DPCRE2_INCLUDE_DIR={pcre2_include}",
            f"-DPCRE2_LIBRARY={pcre2_lib}/libpcre2-8.{ext}",
        ],
        env=env,
    )
