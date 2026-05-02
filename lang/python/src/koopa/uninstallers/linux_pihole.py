"""Uninstall Pi-hole."""

from __future__ import annotations

import shutil
import subprocess
import sys


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall Pi-hole."""
    if not shutil.which("pihole"):
        print("Pi-hole is not installed.")
        return
    if not sys.stdin.isatty():
        msg = "Pi-hole uninstall requires an interactive session."
        raise RuntimeError(msg)
    subprocess.run(["pihole", "uninstall"], check=False)
