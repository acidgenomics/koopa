"""Install libluv."""

from __future__ import annotations

import os

from koopa.archive import extract
from koopa.build import activate_app, app_prefix, cmake_build, shared_ext
from koopa.download import download
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libluv."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libuv", "luajit", env=env)
    libuv_prefix = app_prefix("libuv")
    luajit_prefix = app_prefix("luajit")
    ext = shared_ext()
    luajit_ver = _detect_luajit_version(luajit_prefix)
    luajit_maj_min = major_minor_version(luajit_ver)
    url = f"https://github.com/luvit/luv/archive/{version}.tar.gz"
    download_extract_cd(url)
    compat_url = "https://github.com/keplerproject/lua-compat-5.3/archive/v0.13.tar.gz"
    compat_tarball = download(compat_url)
    extract(compat_tarball, "deps/lua-compat-5.3")
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_MODULE=OFF",
            "-DBUILD_SHARED_LIBS=ON",
            "-DBUILD_STATIC_LIBS=OFF",
            "-DLUA_BUILD_TYPE=System",
            f"-DLUA_INCLUDE_DIR={luajit_prefix}/include/luajit-{luajit_maj_min}",
            f"-DLUA_LIBRARIES={luajit_prefix}/lib/libluajit-5.1.{ext}",
            f"-DLIBUV_INCLUDE_DIR={libuv_prefix}/include",
            f"-DLIBUV_LIBRARIES={libuv_prefix}/lib/libuv.{ext}",
            "-DWITH_SHARED_LIBUV=ON",
        ],
        env=env,
    )


def _detect_luajit_version(luajit_prefix: str) -> str:
    """Detect installed LuaJIT version from include directory."""
    inc_dir = os.path.join(luajit_prefix, "include")
    for entry in os.listdir(inc_dir):
        if entry.startswith("luajit-"):
            ver_file = os.path.join(inc_dir, entry, "luajit.h")
            if os.path.exists(ver_file):
                with open(ver_file) as fh:
                    for line in fh:
                        if "LUAJIT_VERSION" in line and '"' in line:
                            parts = line.split('"')
                            if len(parts) >= 2:
                                return parts[1].replace("LuaJIT ", "")
    return "2.1"
