"""Install docker-credential-helpers."""

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
    """Install docker-credential-helpers."""
    env = activate_app("go", "make", "pkg-config", build_only=True)
    make = locate("make")
    url = (
        f"https://github.com/docker/docker-credential-helpers/archive/"
        f"v{version}.tar.gz"
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    if sys.platform == "darwin":
        subprocess.run(
            [make, "osxkeychain"], env=subprocess_env, check=True
        )
        shutil.copy2(
            "bin/build/docker-credential-osxkeychain",
            os.path.join(bin_dir, "docker-credential-osxkeychain"),
        )
    else:
        subprocess.run([make, "pass"], env=subprocess_env, check=True)
        shutil.copy2(
            "bin/build/docker-credential-pass",
            os.path.join(bin_dir, "docker-credential-pass"),
        )
