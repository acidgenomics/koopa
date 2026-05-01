"""Install lua."""

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
    """Install lua."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    url = f"https://www.lua.org/ftp/lua-{version}.tar.gz"
    download_extract_cd(url)
    platform = "macosx" if sys.platform == "darwin" else "linux"
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}", platform],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install", f"INSTALL_TOP={prefix}"],
        env=subprocess_env,
        check=True,
    )
