"""Install Homebrew."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.system import is_macos


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Homebrew."""
    brew = shutil.which("brew")
    if brew is not None:
        msg = "Homebrew is already installed."
        raise RuntimeError(msg)
    if is_macos():
        clt_dir = "/Library/Developer/CommandLineTools"
        if not os.path.isdir(clt_dir):
            msg = "Xcode Command Line Tools required. Run 'koopa install xcode-clt'."
            raise RuntimeError(msg)
    url = "https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
    script = download(url)
    os.chmod(script, 0o755)
    print("Installing Homebrew.", file=sys.stderr)
    env = os.environ.copy()
    env["NONINTERACTIVE"] = "1"
    subprocess.run(["bash", script], env=env, check=True)
