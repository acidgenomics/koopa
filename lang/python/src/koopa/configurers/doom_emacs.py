"""Configure Doom Emacs for the current user."""

import os
import subprocess

from koopa.alert import alert_info, warn
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.xdg import xdg_config_home, xdg_data_home

_EARLY_INIT_MARKER = "Managed by koopa"

_EARLY_INIT_TEMPLATE = """\
;; -*- mode: emacs-lisp; lexical-binding: t; no-byte-compile: t -*-
;; Managed by koopa: koopa configure user doom-emacs
;; Bootstrap Doom Emacs from koopa's install prefix, keeping package state
;; outside it so a version bump does not destroy it.
(setenv "EMACSDIR" "{emacsdir}")
(setenv "DOOMLOCALDIR" "{doomlocaldir}")
(setq early-init-file (expand-file-name "early-init.el" "{emacsdir}"))
(load early-init-file nil t 'nosuffix)
"""


def _write_early_init_shim(*, emacsdir: str, doomlocaldir: str) -> None:
    """Write the bootstrap shim so plain 'emacs' loads Doom.

    Skips the write if a non-koopa early-init.el already exists, so a
    hand-written file is never clobbered.

    Parameters
    ----------
    emacsdir : str
        Doom Emacs ``EMACSDIR`` path, the shared install's libexec directory.
    doomlocaldir : str
        Doom Emacs ``DOOMLOCALDIR`` path, where package state is stored
        outside the shared install prefix.
    """
    emacs_dir = os.path.join(xdg_config_home(), "emacs")
    path = os.path.join(emacs_dir, "early-init.el")
    if os.path.isfile(path):
        with open(path) as f:
            existing = f.read()
        if _EARLY_INIT_MARKER not in existing:
            warn(f"Skipping unmanaged early-init.el: {path}")
            return
    os.makedirs(emacs_dir, exist_ok=True)
    content = _EARLY_INIT_TEMPLATE.format(emacsdir=emacsdir, doomlocaldir=doomlocaldir)
    with open(path, "w") as f:
        f.write(content)


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
    opt_doom = os.path.join(opt_prefix(), "doom-emacs")
    if not os.path.isdir(opt_doom):
        msg = f"Doom Emacs shared install not found: {opt_doom}"
        raise FileNotFoundError(msg)
    libexec = os.path.join(opt_doom, "libexec")
    doom = os.path.join(libexec, "bin", "doom")
    if not os.path.isfile(doom):
        msg = f"doom CLI not found: {doom}"
        raise FileNotFoundError(msg)
    home = os.path.expanduser("~")
    doom_dir = os.path.join(home, ".config", "doom")
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    env["EMACSDIR"] = libexec
    env["DOOMDIR"] = doom_dir
    doom_local_dir = os.path.join(xdg_data_home(), "doom")
    env["DOOMLOCALDIR"] = doom_local_dir
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
    _write_early_init_shim(emacsdir=libexec, doomlocaldir=doom_local_dir)
