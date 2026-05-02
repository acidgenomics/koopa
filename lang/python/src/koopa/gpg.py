"""GPG helper functions.

Converted from Bash functions in ``lang/bash/functions/core/gpg-*.sh``.
"""

from __future__ import annotations

import shutil
import subprocess


def gpg_prompt() -> None:
    """Force GPG to prompt for password."""
    gpg = shutil.which("gpg")
    if gpg is None:
        msg = "gpg is not installed."
        raise RuntimeError(msg)
    subprocess.run(
        [gpg, "-s"],
        input="",
        text=True,
        check=True,
    )


def gpg_reload() -> None:
    """Force reload the GPG agent."""
    gpg_connect_agent = shutil.which("gpg-connect-agent")
    if gpg_connect_agent is None:
        msg = "gpg-connect-agent is not installed."
        raise RuntimeError(msg)
    subprocess.run(
        [gpg_connect_agent, "reloadagent", "/bye"],
        check=True,
    )


def gpg_restart() -> None:
    """Restart GPG agent."""
    gpgconf = shutil.which("gpgconf")
    if gpgconf is None:
        msg = "gpgconf is not installed."
        raise RuntimeError(msg)
    subprocess.run(
        [gpgconf, "--kill", "gpg-agent"],
        check=True,
    )
