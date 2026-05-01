"""Install luajit."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate, shared_ext
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install luajit."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    ext = shared_ext()
    maj_min_ver = major_minor_version(version)
    url = f"https://github.com/LuaJIT/LuaJIT/archive/refs/tags/v{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    if sys.platform == "darwin":
        subprocess_env["MACOSX_DEPLOYMENT_TARGET"] = "11.0"
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=subprocess_env,
        check=True,
    )
    lib_dir = os.path.join(prefix, "lib")
    if sys.platform == "darwin":
        ln(
            f"libluajit-5.1.{ext}",
            os.path.join(lib_dir, f"libluajit-5.1.{maj_min_ver}.{ext}"),
        )
    else:
        ln(
            f"libluajit-5.1.{ext}.{version}",
            os.path.join(lib_dir, f"libluajit-5.1.{ext}.{maj_min_ver}"),
        )
