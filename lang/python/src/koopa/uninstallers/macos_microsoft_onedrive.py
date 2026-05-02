"""Uninstall Microsoft OneDrive on macOS."""

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
    """Uninstall Microsoft OneDrive on macOS."""
    home = os.path.expanduser("~")
    # System path (requires sudo).
    app = "/Applications/OneDrive.app"
    if os.path.lexists(app):
        rm(app, sudo=True)
    # User paths (no sudo).
    user_paths = [
        os.path.join(
            home,
            "Library/Containers/"
            "com.microsoft.OneDrive-mac.FinderSync",
        ),
        os.path.join(
            home,
            "Library/Application Scripts/"
            "com.microsoft.OneDrive-mac.FinderSync",
        ),
        os.path.join(
            home,
            "Library/Group Containers/"
            "UBF8T346G9.OneDriveSyncClientSuite",
        ),
    ]
    for path in user_paths:
        if os.path.lexists(path):
            rm(path)
