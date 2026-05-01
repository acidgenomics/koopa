"""Install unzip."""

from __future__ import annotations

import os
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
    """Install unzip."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://koopa.acidgenomics.com/src/unzip/unzip-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    cflags = (
        "-DACORN_FTYPE_NFS "
        "-DWILD_STOP_AT_DIR "
        "-DLARGE_FILE_SUPPORT "
        "-DUNICODE_SUPPORT "
        "-DUNICODE_WCHAR "
        "-DUTF8_MAYBE_NATIVE "
        "-DNO_LCHMOD "
        "-DDATE_FORMAT=DF_YMD "
        "-DUSE_BZIP2 "
        "-DIZ_HAVE_STRDUP "
        '-DLOCALEDIR=L\\"/usr/share/locale\\" '
        "-DNO_WORKING_ISPRINT "
    )
    if sys.platform != "darwin":
        cflags += "-DNO_SETLOCALE "
    subprocess_env["CFLAGS"] = cflags
    jobs = os.cpu_count() or 1
    target = "macosx" if sys.platform == "darwin" else "generic"
    subprocess.run(
        [make, f"--jobs={jobs}", f"-f", "unix/Makefile", target],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            "-f",
            "unix/Makefile",
            "install",
            f"prefix={prefix}",
            f"MANDIR={prefix}/share/man/man1",
        ],
        env=subprocess_env,
        check=True,
    )
