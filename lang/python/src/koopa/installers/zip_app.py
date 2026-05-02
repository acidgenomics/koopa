"""Install zip."""

from __future__ import annotations

import os
import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install zip."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    ver_nodot = version.replace(".", "")
    url = f"https://sourceforge.net/projects/infozip/files/Zip%203.x%20%28latest%29/{version}/zip{ver_nodot}.tar.gz/download"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}", "-f", "unix/Makefile", "generic"],
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
