"""Subprocess execution helpers."""

import subprocess


def run(
    *args: str,
    sudo: bool = False,
    capture: bool = False,
    check: bool = True,
    cwd: str | None = None,
) -> subprocess.CompletedProcess:
    """Run a command with optional sudo, capture, and cwd."""
    cmd = list(args)
    if sudo:
        cmd = ["sudo", *cmd]
    return subprocess.run(cmd, capture_output=capture, text=True, check=check, cwd=cwd)
