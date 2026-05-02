"""Install Homebrew Bundle."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.system import is_macos


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Homebrew Bundle."""
    if is_macos():
        clt_dir = "/Library/Developer/CommandLineTools"
        if not os.path.isdir(clt_dir):
            msg = "Xcode Command Line Tools required."
            raise RuntimeError(msg)
    brew = shutil.which("brew")
    if brew is None:
        msg = "Homebrew is not installed."
        raise FileNotFoundError(msg)
    xdg_config = os.environ.get(
        "XDG_CONFIG_HOME",
        os.path.join(os.path.expanduser("~"), ".config"),
    )
    brewfile = os.path.join(xdg_config, "homebrew", "brewfile")
    if not os.path.isfile(brewfile):
        msg = (
            f"Brewfile at '{brewfile}' does not exist. "
            "Run 'koopa install dotfiles' and "
            "'koopa configure user dotfiles' to resolve."
        )
        raise FileNotFoundError(msg)
    print(f"Brewfile: {brewfile}", file=sys.stderr)
    subprocess.run([brew, "analytics", "off"], check=True)
    subprocess.run(
        [
            brew,
            "bundle",
            "install",
            "--force",
            "--no-lock",
            "--no-upgrade",
            f"--file={brewfile}",
        ],
        check=True,
    )
