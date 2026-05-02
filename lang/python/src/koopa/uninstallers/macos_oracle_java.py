"""Uninstall Oracle Java on macOS."""

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
    """Uninstall Oracle Java on macOS."""
    home = os.path.expanduser("~")
    # System paths (require sudo).
    system_paths = [
        "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin",
        "/Library/LaunchAgents/com.oracle.java.Java-Updater.plist",
        "/Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist",
        "/Library/PreferencePanes/JavaControlPanel.prefPane",
        "/Library/Preferences/com.oracle.java.Helper-Tool.plist",
    ]
    for path in system_paths:
        if os.path.lexists(path):
            rm(path, sudo=True)
    # User paths (no sudo).
    user_paths = [
        os.path.join(
            home,
            "Library/Caches/com.oracle.java.Java-Updater",
        ),
        os.path.join(
            home,
            "Library/Application Support/Oracle/Java",
        ),
        os.path.join(
            home,
            "Library/Preferences/com.apple.java.util.prefs.plist",
        ),
        os.path.join(
            home,
            "Library/Preferences/com.oracle.java.JavaAppletPlugin.plist",
        ),
    ]
    user_patterns = [
        os.path.join(
            home,
            "Library/Safari/LocalStorage/https_www.java.com_0.localstorage*",
        ),
    ]
    for path in user_paths:
        if os.path.lexists(path):
            rm(path)
    for pattern in user_patterns:
        for path in glob.glob(pattern):
            rm(path)
