"""System configuration functions.

Converted from Bash/POSIX shell functions: configure-conda, configure-git,
configure-r-repos, configure-ssh-key, is-github-ssh-enabled,
is-gitlab-ssh-enabled, ip-address, ip-info, hostname, fqdn, etc.
"""

from __future__ import annotations

import json
import os
import socket
import subprocess
import urllib.request
from pathlib import Path


def configure_conda(prefix: str | None = None) -> None:
    """Configure conda with recommended settings."""
    args = ["conda", "config"]
    settings = {
        "auto_activate_base": "false",
        "auto_update_conda": "true",
        "channel_priority": "strict",
        "channels": ["conda-forge", "bioconda", "defaults"],
    }
    for key, value in settings.items():
        if isinstance(value, list):
            for v in value:
                subprocess.run(
                    [*args, "--add", key, v],
                    capture_output=True,
                    check=True,
                )
        else:
            subprocess.run(
                [*args, "--set", key, value],
                capture_output=True,
                check=True,
            )


def configure_git(
    name: str,
    email: str,
    *,
    editor: str = "vim",
    default_branch: str = "main",
) -> None:
    """Configure git global settings."""
    settings = {
        "user.name": name,
        "user.email": email,
        "core.editor": editor,
        "init.defaultBranch": default_branch,
        "pull.rebase": "false",
        "push.autoSetupRemote": "true",
    }
    for key, value in settings.items():
        subprocess.run(
            ["git", "config", "--global", key, value],
            check=True,
        )


def configure_ssh_key(
    email: str,
    *,
    key_type: str = "ed25519",
    path: str | None = None,
) -> str:
    """Generate an SSH key pair."""
    if path is None:
        path = os.path.expanduser(f"~/.ssh/id_{key_type}")
    if os.path.isfile(path):
        return path
    Path(os.path.dirname(path)).mkdir(parents=True, exist_ok=True, mode=0o700)
    subprocess.run(
        ["ssh-keygen", "-t", key_type, "-C", email, "-f", path, "-N", ""],
        check=True,
    )
    return path


def is_github_ssh_enabled() -> bool:
    """Check if GitHub SSH access is configured."""
    result = subprocess.run(
        ["ssh", "-T", "git@github.com"],
        capture_output=True,
        text=True,
        check=False,
    )
    return "successfully authenticated" in result.stderr.lower()


def is_gitlab_ssh_enabled() -> bool:
    """Check if GitLab SSH access is configured."""
    result = subprocess.run(
        ["ssh", "-T", "git@gitlab.com"],
        capture_output=True,
        text=True,
        check=False,
    )
    return "welcome" in result.stderr.lower()


def ip_address() -> str:
    """Get public IP address."""
    try:
        with urllib.request.urlopen("https://api.ipify.org") as resp:
            return resp.read().decode().strip()
    except Exception:
        return ""


def ip_info() -> dict:
    """Get IP geolocation info."""
    try:
        with urllib.request.urlopen("https://ipinfo.io/json") as resp:
            return json.loads(resp.read().decode())
    except Exception:
        return {}


def hostname() -> str:
    """Get hostname."""
    return socket.gethostname()


def fqdn() -> str:
    """Get fully qualified domain name."""
    return socket.getfqdn()
