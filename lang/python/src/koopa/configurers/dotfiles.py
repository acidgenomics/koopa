"""Configure dotfiles."""

from __future__ import annotations

import os
import shutil
import subprocess

from koopa.file_ops import ln
from koopa.prefix import opt_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure dotfiles for current user.

    Links opt_prefix/dotfiles to the dotfiles config prefix, then runs
    the install script(s).
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    bash = shutil.which("bash")
    if bash is None:
        msg = "Bash is required."
        raise RuntimeError(msg)
    opt_dotfiles = os.path.join(opt_prefix(), "dotfiles")
    if not os.path.isdir(opt_dotfiles):
        msg = f"Dotfiles directory not found: {opt_dotfiles}"
        raise FileNotFoundError(msg)
    home = os.path.expanduser("~")
    dotfiles_prefix = os.path.join(home, ".config", "koopa", "dotfiles")
    dotfiles_work_prefix = os.path.join(
        home, ".config", "koopa", "dotfiles-work"
    )
    dotfiles_private_prefix = os.path.join(
        home, ".config", "koopa", "dotfiles-private"
    )
    ln(opt_dotfiles, dotfiles_prefix)
    install_script = os.path.join(dotfiles_prefix, "install")
    if not os.path.isfile(install_script):
        msg = f"Install script not found: {install_script}"
        raise FileNotFoundError(msg)
    subprocess.run([bash, install_script], check=True)
    work_install_script = os.path.join(dotfiles_work_prefix, "install")
    if os.path.isfile(work_install_script):
        subprocess.run([bash, work_install_script], check=True)
    private_install_script = os.path.join(dotfiles_private_prefix, "install")
    if os.path.isfile(private_install_script):
        subprocess.run([bash, private_install_script], check=True)
