"""Install pigz."""

from __future__ import annotations

import os
import shutil
import subprocess

from koopa.build import activate_app, app_prefix, locate
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pigz."""
    env = activate_app("make", build_only=True)
    env = activate_app("zlib", env=env)
    make = locate("make")
    zlib_prefix = app_prefix("zlib")
    url = f"https://zlib.net/pigz/pigz-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    subprocess_env["CC"] = "gcc"
    subprocess_env["CFLAGS"] = f"-I{zlib_prefix}/include " + subprocess_env.get("CFLAGS", "")
    subprocess_env["LDFLAGS"] = f"-L{zlib_prefix}/lib " + subprocess_env.get("LDFLAGS", "")
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    man_dir = os.path.join(prefix, "share", "man", "man1")
    os.makedirs(bin_dir, exist_ok=True)
    os.makedirs(man_dir, exist_ok=True)
    shutil.copy2("pigz", os.path.join(bin_dir, "pigz"))
    shutil.copy2("unpigz", os.path.join(bin_dir, "unpigz"))
    shutil.copy2("pigz.1", os.path.join(man_dir, "pigz.1"))
    ln("pigz.1", os.path.join(man_dir, "unpigz.1"))
