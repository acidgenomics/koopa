"""Install cpufetch."""

from __future__ import annotations

import os
import shutil
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
    """Install cpufetch."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://github.com/Dr-Noob/cpufetch/archive/v{version}.tar.gz"
    download_extract_cd(url)
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=env.to_env_dict(),
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    man_dir = os.path.join(prefix, "share", "man", "man1")
    os.makedirs(bin_dir, exist_ok=True)
    os.makedirs(man_dir, exist_ok=True)
    shutil.copy2("cpufetch", os.path.join(bin_dir, "cpufetch"))
    shutil.copy2("cpufetch.1", os.path.join(man_dir, "cpufetch.1"))
