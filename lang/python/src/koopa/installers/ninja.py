"""Install ninja."""

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
    """Install ninja."""
    env = activate_app("python", build_only=True)
    python = locate("python3")
    url = f"https://github.com/ninja-build/ninja/archive/v{version}.tar.gz"
    download_extract_cd(url)
    subprocess.run(
        [python, "configure.py", "--bootstrap"],
        env=env.to_env_dict(),
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    shutil.copy2("ninja", os.path.join(bin_dir, "ninja"))
