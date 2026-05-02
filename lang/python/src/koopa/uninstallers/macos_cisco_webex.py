"""Uninstall Cisco WebEx on macOS."""

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
    """Uninstall Cisco WebEx on macOS."""
    home = os.path.expanduser("~")
    # System path (requires sudo).
    app = "/Applications/Cisco Webex Meetings.app"
    if os.path.lexists(app):
        rm(app, sudo=True)
    # User paths (no sudo).
    user_paths = [
        os.path.join(
            home,
            "Library/Application Support/Cisco/WebEx Meetings",
        ),
        os.path.join(
            home,
            "Library/Application Support/WebEx Folder",
        ),
        os.path.join(
            home,
            "Library/Caches/com.webex.meetingmanager",
        ),
        os.path.join(
            home,
            "Library/Cookies/com.webex.meetingmanager.binarycookies",
        ),
        os.path.join(
            home,
            "Library/Group Containers/group.com.cisco.webex.meetings",
        ),
        os.path.join(
            home,
            "Library/Internet Plug-Ins/Webex.plugin",
        ),
        os.path.join(home, "Library/Logs/WebexMeetings"),
        os.path.join(home, "Library/Logs/webexmta"),
        os.path.join(
            home,
            "Library/WebKit/com.webex.meetingmanager",
        ),
    ]
    user_patterns = [
        os.path.join(
            home,
            "Library/Application Support/com.apple.sharedfilelist/"
            "com.apple.LSSharedFileList.ApplicationRecentDocuments/"
            "*.webex.*.sfl",
        ),
        os.path.join(home, "Library/Caches/com.cisco.webex*"),
        os.path.join(home, "Library/Preferences/*.webex.*.plist"),
        os.path.join(home, "Library/Receipts/*.webex.*"),
        os.path.join(
            home,
            "Library/Safari/LocalStorage/*.webex.com*",
        ),
    ]
    for path in user_paths:
        if os.path.lexists(path):
            rm(path)
    for pattern in user_patterns:
        for path in glob.glob(pattern):
            rm(path)
