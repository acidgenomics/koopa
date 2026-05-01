"""Install pbzip2."""

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
    """Install pbzip2."""
    env = activate_app("make", build_only=True)
    if sys.platform != "darwin":
        env = activate_app("bzip2", env=env)
    make = locate("make")
    url = (
        f"https://launchpad.net/pbzip2/{version[0]}.{version[1]}.x/"
        f"{version}/+download/pbzip2-{version}.tar.gz"
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    cc = shutil.which("gcc") or "gcc"
    subprocess_env["CC"] = cc
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    shutil.copy2("pbzip2", os.path.join(bin_dir, "pbzip2"))
