"""Install openblas."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate, shared_ext
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install openblas."""
    env = activate_app("make", "pkg-config", build_only=True)
    make = locate("make")
    ext = shared_ext()
    cc = os.environ.get("CC", "gcc")
    use_openmp = 0 if sys.platform == "darwin" else 1
    url = f"https://github.com/xianyi/OpenBLAS/archive/v{version}.tar.gz"
    download_extract_cd(url)
    makefile_rule = f"""\
CC={cc}
NOFORTRAN=1
NUM_THREADS=56
USE_OPENMP={use_openmp}
"""
    with open("Makefile.rule", "a") as fh:
        fh.write(makefile_rule)
    subprocess_env = env.to_env_dict()
    subprocess.run(
        [make, "VERBOSE=1", "--jobs=1", "libs", "netlib", "shared"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, f"PREFIX={prefix}", "install"],
        env=subprocess_env,
        check=True,
    )
    lib_dir = os.path.join(prefix, "lib")
    remove_static_libs(prefix)
    ln(f"libopenblas.{ext}", os.path.join(lib_dir, f"libblas.{ext}"))
