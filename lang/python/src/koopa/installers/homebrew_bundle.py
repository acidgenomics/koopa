"""Install Homebrew Bundle."""

import os
import shutil
import subprocess
import sys

from koopa.system import is_macos
from koopa.xdg import xdg_config_home


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Homebrew Bundle.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    if is_macos():
        clt_dir = "/Library/Developer/CommandLineTools"
        if not os.path.isdir(clt_dir):
            msg = "Xcode Command Line Tools required."
            raise RuntimeError(msg)
    brew = shutil.which("brew")
    if brew is None:
        msg = "Homebrew is not installed."
        raise FileNotFoundError(msg)
    brewfile = os.path.join(xdg_config_home(), "homebrew", "brewfile")
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
            "--no-upgrade",
            f"--file={brewfile}",
        ],
        check=True,
    )
