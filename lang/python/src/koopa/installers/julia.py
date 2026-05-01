"""Install julia."""

from __future__ import annotations

import os
import shutil
import subprocess
import stat

from koopa.download import download
from koopa.file_ops import ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install julia via juliaup."""
    env = os.environ.copy()
    env["JULIAUP_DEPOT_PATH"] = os.path.join(os.getcwd(), "juliaup_depot")
    script = download(
        "https://install.julialang.org",
        output="juliaup-install.sh",
    )
    os.chmod(script, os.stat(script).st_mode | stat.S_IEXEC)
    subprocess.run(
        ["bash", script, "--yes", "--default-channel", version],
        env=env,
        check=True,
    )
    juliaup_home = os.path.expanduser("~/.juliaup")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    juliaup_bin = os.path.join(juliaup_home, "bin")
    if os.path.isdir(juliaup_bin):
        for item in os.listdir(juliaup_bin):
            src = os.path.join(juliaup_bin, item)
            dst = os.path.join(bin_dir, item)
            shutil.copy2(src, dst)
    libexec = os.path.join(prefix, "libexec")
    if os.path.isdir(juliaup_home):
        shutil.copytree(juliaup_home, libexec, dirs_exist_ok=True)
