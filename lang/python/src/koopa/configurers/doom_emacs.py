"""Configure Doom Emacs for the current user."""

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
    """Configure Doom Emacs for the current user.

    Runs 'doom install' (or 'doom sync' if already configured) using the shared
    install. DOOMDIR defaults to ~/.config/doom for the user's private config.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    opt_doom = os.path.join(opt_prefix(), "doom-emacs")
    if not os.path.isdir(opt_doom):
        msg = f"Doom Emacs shared install not found: {opt_doom}"
        raise FileNotFoundError(msg)
    doom = os.path.join(opt_doom, "bin", "doom")
    if not os.path.isfile(doom):
        msg = f"doom CLI not found: {doom}"
        raise FileNotFoundError(msg)
    home = os.path.expanduser("~")
    doom_dir = os.path.join(home, ".config", "doom")
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    env["EMACSDIR"] = opt_doom
    env["DOOMDIR"] = doom_dir
    already_configured = os.path.isfile(os.path.join(doom_dir, "init.el"))
    if already_configured:
        alert_info("Running 'doom sync'.")
        subprocess.run([doom, "sync"], check=True, env=env)
    else:
        os.makedirs(doom_dir, exist_ok=True)
        alert_info("Running 'doom install'.")
        subprocess.run(
            [doom, "install", "--force", "--no-env", "--no-fonts"],
            check=True,
            env=env,
        )
