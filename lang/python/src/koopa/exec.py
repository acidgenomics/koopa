"""Subprocess execution helpers."""

import subprocess


def run(
    *args: str,
    sudo: bool = False,
    capture: bool = False,
    check: bool = True,
    cwd: str | None = None,
) -> subprocess.CompletedProcess:
    """Run a command with optional sudo, capture, and cwd.

    Parameters
    ----------
    *args : str
        Command and arguments to run.
    sudo : bool, optional
        Prepend ``sudo`` to the command.
    capture : bool, optional
        Capture stdout and stderr instead of inheriting the parent process
        streams.
    check : bool, optional
        Raise ``CalledProcessError`` if the command exits with a non-zero
        status.
    cwd : str | None, optional
        Working directory to run the command in.

    Returns
    -------
    subprocess.CompletedProcess
        The completed process, including its return code and any captured
        output.
    """
    cmd = list(args)
    if sudo:
        cmd = ["sudo", *cmd]
    return subprocess.run(cmd, capture_output=capture, text=True, check=check, cwd=cwd)
