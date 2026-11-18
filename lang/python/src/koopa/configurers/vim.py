"""Update Vim plugins for the current user."""

import os
import subprocess
import sys

from koopa.alert import alert_info
from koopa.build import locate
from koopa.prefix import koopa_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Run vim-plug's synchronous plugin update.

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
    vimrc = os.path.expanduser("~/.vimrc")
    if not os.path.isfile(vimrc):
        msg = f"Vim configuration not found: {vimrc}"
        raise FileNotFoundError(msg)
    vim = locate("vim")
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    alert_info("Running headless ':PlugUpdate --sync'.")
    args = [
        vim,
        "-es",
        "-n",
        "-i",
        "NONE",
        "-u",
        vimrc,
        "-V1",
        "-c",
        "PlugUpdate --sync",
        "-c",
        "call writefile(getline(1, '$'), '/dev/stdout', 'a')",
        "-c",
        "if search('^x ', 'nw') | cquit 1 | endif",
        "-c",
        "qa!",
    ]
    try:
        result = subprocess.run(
            args,
            check=True,
            capture_output=True,
            text=True,
            env=env,
        )
    except subprocess.CalledProcessError as exc:
        if exc.stdout:
            sys.stdout.write(exc.stdout)
        if exc.stderr:
            sys.stderr.write(exc.stderr)
        msg = "Vim plugin update failed; see the output above."
        raise RuntimeError(msg) from exc
    if result.stdout:
        sys.stdout.write(result.stdout)
    if verbose and result.stderr:
        sys.stderr.write(result.stderr)
