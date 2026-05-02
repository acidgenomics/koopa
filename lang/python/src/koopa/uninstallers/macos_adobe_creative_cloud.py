"""Uninstall Adobe Creative Cloud on macOS."""

from __future__ import annotations

import glob
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
    """Uninstall Adobe Creative Cloud on macOS."""
    home = os.path.expanduser("~")
    # System paths (require sudo).
    system_patterns = [
        "/Library/Application Support/Adobe*",
        "/Library/Application Support/regid.*.com.adobe",
        "/Library/Caches/com.adobe*",
        "/Library/Caches/com.Adobe*",
        "/Library/Fonts/adobe*",
        "/Library/Fonts/Adobe*",
        "/Library/Preferences/com.adobe*",
        "/Library/Preferences/com.Adobe*",
    ]
    system_paths = [
        "/Library/ScriptingAdditions/Adobe Unit Types.osax",
        "/Users/Shared/Adobe",
    ]
    for pattern in system_patterns:
        for path in glob.glob(pattern):
            rm(path, sudo=True)
    for path in system_paths:
        if os.path.lexists(path):
            rm(path, sudo=True)
    # User paths (no sudo).
    user_patterns = [
        os.path.join(home, "Library/Application Support/Adobe*"),
        os.path.join(home, "Library/Caches/Adobe*"),
        os.path.join(home, "Library/Caches/com.adobe*"),
        os.path.join(home, "Library/Preferences/Adobe*"),
        os.path.join(home, "Library/Preferences/com.adobe*"),
        os.path.join(home, "Library/Preferences/com.Adobe*"),
        os.path.join(home, "Library/Preferences/ByHost/com.adobe*"),
        os.path.join(
            home,
            "Library/Saved Application State/com.adobe*",
        ),
        os.path.join(
            home,
            "Library/Saved Application State/com.Adobe*",
        ),
    ]
    user_paths = [
        os.path.join(home, "Documents/Adobe"),
        os.path.join(home, "Library/Preferences/Macromedia"),
    ]
    for pattern in user_patterns:
        for path in glob.glob(pattern):
            rm(path)
    for path in user_paths:
        if os.path.lexists(path):
            rm(path)
