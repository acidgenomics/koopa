"""Configure Neovim for the current user."""

import filecmp
import os
import subprocess

from koopa.alert import alert_info, alert_note
from koopa.build import locate
from koopa.prefix import koopa_prefix, opt_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure Neovim for the current user.

    Runs a headless ':Lazy! sync' (install missing plugins, clean removed
    ones, update, and refresh the lockfile). lazy.nvim auto-installs missing
    plugins at startup but never cleans, so this is the only thing that
    removes an orphaned plugin left behind by a removed spec.

    Parameters
    ----------
    name : str
        Application name.
    platform : str
        Operating system platform slug.
    mode : str
        Installation mode (e.g. ``"user"``).
    verbose : bool, optional
        Print verbose output.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    nvim = locate("nvim")
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    alert_info("Running headless ':Lazy! sync'.")
    subprocess.run([nvim, "--headless", "+Lazy! sync", "+qa"], check=True, env=env)

    home = os.path.expanduser("~")
    deployed_lock = os.path.join(home, ".config", "nvim", "lazy-lock.json")
    source_lock = os.path.join(
        opt_prefix(), "dotfiles", "chezmoi", "dot_config", "nvim", "lazy-lock.json"
    )
    if not os.path.isfile(source_lock):
        return
    if not os.path.isfile(deployed_lock) or not filecmp.cmp(
        deployed_lock, source_lock, shallow=False
    ):
        alert_note(
            "lazy-lock.json changed. Re-add it to the chezmoi source and commit:\n"
            f"  chezmoi re-add --source={os.path.join(opt_prefix(), 'dotfiles', 'chezmoi')}"
            f" {deployed_lock}"
        )
