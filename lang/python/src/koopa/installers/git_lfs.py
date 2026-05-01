"""Install git-lfs."""

from __future__ import annotations

import os
import subprocess

from koopa.build import activate_app, locate
from koopa.file_ops import cp_to_dir
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install git-lfs."""
    env = activate_app("go", "make", build_only=True)
    make = locate("make")
    url = (
        f"https://github.com/git-lfs/git-lfs/releases/download/"
        f"v{version}/git-lfs-v{version}.tar.gz"
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}", "VERBOSE=1"],
        env=subprocess_env,
        check=True,
    )
    os.makedirs(os.path.join(prefix, "bin"), exist_ok=True)
    cp_to_dir("bin", prefix)
