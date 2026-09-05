"""Configure sshd."""

import sys

from koopa.os_linux import configure_system_sshd


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure system sshd with koopa defaults.

    Parameters
    ----------
    name : str
        Application name.
    platform : str
        Operating system platform slug.
    mode : str
        Installation mode (e.g. ``"system"``).
    verbose : bool, optional
        Print verbose output.
    """
    if sys.platform == "darwin":
        msg = "sshd configuration is not supported on macOS."
        raise NotImplementedError(msg)
    configure_system_sshd()
