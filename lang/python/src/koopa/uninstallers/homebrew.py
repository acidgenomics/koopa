"""Uninstall Homebrew."""

from __future__ import annotations

import os
import subprocess
import tempfile

from koopa.file_ops import chmod, rm


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall Homebrew."""
    url = (
        "https://raw.githubusercontent.com/Homebrew/install"
        "/master/uninstall.sh"
    )
    tmp = tempfile.mktemp(suffix=".sh", prefix="koopa-homebrew-uninstall-")
    subprocess.run(
        ["curl", "-fsSL", "-o", tmp, url],
        check=True,
    )
    chmod(tmp, "u+x")
    env = os.environ.copy()
    env["NONINTERACTIVE"] = "1"
    subprocess.run([tmp, "--force"], env=env, check=False)
    if os.path.exists(tmp):
        os.unlink(tmp)
    if platform == "linux" or os.path.exists("/home/linuxbrew"):
        linuxbrew = "/home/linuxbrew"
        if os.path.exists(linuxbrew):
            rm(linuxbrew, sudo=True)
