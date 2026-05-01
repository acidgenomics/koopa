"""Install woff2."""

from __future__ import annotations

import glob
import os
import shutil

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install woff2."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("brotli", env=env)
    url = f"https://github.com/nicolo-ribaudo/woff2/archive/v{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=["-DCANONICAL_PREFIXES=ON"],
        env=env,
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    for f in glob.glob("build/woff2_*"):
        if os.access(f, os.X_OK):
            shutil.copy2(f, os.path.join(bin_dir, os.path.basename(f)))
