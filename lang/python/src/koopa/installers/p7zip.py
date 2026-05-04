"""Install p7zip."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install p7zip."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://github.com/p7zip-project/p7zip/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    if sys.platform == "darwin":
        makefile = "makefile.macosx_llvm_64bits"
    else:
        makefile = "makefile.linux_any_cpu_gcc_4.X"
    subprocess_env = env.to_env_dict()
    cc = shutil.which("gcc") or "gcc"
    cxx = shutil.which("g++") or "g++"
    subprocess_env["CC"] = cc
    subprocess_env["CXX"] = cxx
    jobs = os.cpu_count() or 1
    cflags = subprocess_env.get("CFLAGS", "")
    cxxflags = subprocess_env.get("CXXFLAGS", "")
    ldflags = subprocess_env.get("LDFLAGS", "")
    shutil.copy(makefile, "makefile.machine")
    subprocess.run(
        [
            make,
            f"--jobs={jobs}",
            "all3",
            f"ALLFLAGS_C={cflags}",
            f"ALLFLAGS_CPP={cxxflags}",
            f"CC={cc}",
            f"CXX={cxx}",
            f"LDFLAGS={ldflags}",
        ],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            "install",
            f"DEST_HOME={prefix}",
            f"DEST_BIN={prefix}/bin",
            f"DEST_MAN={prefix}/share/man",
        ],
        env=subprocess_env,
        check=True,
    )
