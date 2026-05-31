"""Configure Emacs Prelude for the current user."""

import os
import subprocess

from koopa.alert import alert_info
from koopa.prefix import koopa_prefix, opt_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure Emacs Prelude for the current user.

    Bootstraps Prelude packages by loading init.el from the shared install.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    opt_prelude = os.path.join(opt_prefix(), "emacs-prelude")
    if not os.path.isdir(opt_prelude):
        msg = f"Emacs Prelude shared install not found: {opt_prelude}"
        raise FileNotFoundError(msg)
    libexec = os.path.join(opt_prelude, "libexec")
    init_el = os.path.join(libexec, "init.el")
    if not os.path.isfile(init_el):
        msg = f"Prelude init.el not found: {init_el}"
        raise FileNotFoundError(msg)
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    alert_info("Running Emacs Prelude package bootstrap.")
    subprocess.run(
        ["emacs", "--no-window-system", "--batch", "--load", init_el],
        check=True,
        env=env,
    )
