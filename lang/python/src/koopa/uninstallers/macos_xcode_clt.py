"""Uninstall Xcode CLT on macOS."""

from __future__ import annotations

import os

from koopa.file_ops import rm


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall Xcode CLT on macOS."""
    clt_dir = "/Library/Developer/CommandLineTools"
    if not os.path.exists(clt_dir):
        return
    rm(clt_dir, sudo=True)
