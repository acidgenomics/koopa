"""Install Lmod."""

from __future__ import annotations

import os
import re
import subprocess

from koopa.archive import extract
from koopa.build import activate_app, app_prefix
from koopa.download import download
from koopa.file_ops import init_dir
from koopa.system import cpu_count


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Lmod."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app("zlib", "lua", "luarocks", "tcl-tk", env=env)
    subprocess_env = env.to_env_dict()
    lua_prefix = app_prefix("lua")
    lua_bin = os.path.join(lua_prefix, "bin", "lua")
    luac_bin = os.path.join(lua_prefix, "bin", "luac")
    luarocks_bin = os.path.join(app_prefix("luarocks"), "bin", "luarocks")
    jobs = cpu_count()
    libexec = os.path.join(prefix, "libexec")
    init_dir(libexec)
    apps_dir = os.path.join(prefix, "apps")
    data_dir = os.path.join(libexec, "moduleData")
    url = f"https://github.com/TACC/Lmod/archive/{version}.tar.gz"
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    rocks = ["luaposix", "luafilesystem"]
    for rock in rocks:
        subprocess.run(
            [
                luarocks_bin,
                f"--lua-dir={lua_prefix}",
                "install",
                "--tree",
                libexec,
                rock,
            ],
            env=subprocess_env,
            check=True,
        )
    result = subprocess.run(
        [lua_bin, "-v"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    )
    lua_ver_output = result.stderr.strip() or result.stdout.strip()
    match = re.search(r"(\d+\.\d+)", lua_ver_output)
    lua_compat_ver = match.group(1) if match else "5.4"
    lua_path_parts = [
        f"{libexec}/share/lua/{lua_compat_ver}/?.lua",
        f"{libexec}/share/lua/{lua_compat_ver}/?/init.lua",
        f"{lua_prefix}/share/lua/{lua_compat_ver}/?.lua",
        f"{lua_prefix}/share/lua/{lua_compat_ver}/?/init.lua",
    ]
    lua_cpath_parts = [
        f"{libexec}/lib/lua/{lua_compat_ver}/?.so",
        f"{lua_prefix}/lib/lua/{lua_compat_ver}/?.so",
    ]
    subprocess_env["LUAROCKS_PREFIX"] = libexec
    subprocess_env["LUA_PATH"] = ";".join(lua_path_parts) + ";"
    subprocess_env["LUA_CPATH"] = ";".join(lua_cpath_parts) + ";"
    conf_args = [
        f"--prefix={apps_dir}",
        "--with-allowRootUse=no",
        f"--with-lua={lua_bin}",
        f"--with-luac={luac_bin}",
        f"--with-spiderCacheDir={data_dir}/cacheDir",
        f"--with-updateSystemFn={data_dir}/system.txt",
    ]
    subprocess.run(
        ["./configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["make", f"-j{jobs}", "VERBOSE=1"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["make", "install"],
        env=subprocess_env,
        check=True,
    )
