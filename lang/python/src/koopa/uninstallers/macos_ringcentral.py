"""Uninstall RingCentral on macOS."""

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
    """Uninstall RingCentral on macOS."""
    home = os.path.expanduser("~")
    # System path (requires sudo).
    app = "/Applications/RingCentral Meetings.app"
    if os.path.lexists(app):
        rm(app, sudo=True)
    # User paths (no sudo).
    user_paths = [
        os.path.join(
            home,
            "Library/Application Support/RingCentral Meetings",
        ),
        os.path.join(
            home,
            "Library/Caches/us.zoom.ringcentral",
        ),
        os.path.join(
            home,
            "Library/Internet Plug-Ins/RingCentralMeetings.plugin",
        ),
        os.path.join(
            home,
            "Library/Internet Plug-Ins/"
            "RingCentralMeetings.plugin/Contents/MacOS/"
            "RingCentralMeetings",
        ),
        os.path.join(home, "Library/Logs/RingCentralMeetings"),
        os.path.join(
            home,
            "Preferences/RingcentralChat.plist",
        ),
        os.path.join(
            home,
            "Preferences/us.zoom.ringcentral.plist",
        ),
    ]
    for path in user_paths:
        if os.path.lexists(path):
            rm(path)
