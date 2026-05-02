"""Uninstall Docker on macOS."""

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
    """Uninstall Docker on macOS."""
    home = os.path.expanduser("~")
    user_paths = [
        os.path.join(
            home,
            "Library/Application Scripts/com.docker.helper",
        ),
        os.path.join(
            home,
            "Library/Application Scripts/group.com.docker",
        ),
        os.path.join(
            home,
            "Library/Application Support/Docker Desktop",
        ),
        os.path.join(home, "Library/Caches/com.docker.docker"),
        os.path.join(
            home,
            "Library/Containers/com.docker.docker",
        ),
        os.path.join(
            home,
            "Library/Group Containers/group.com.docker",
        ),
        os.path.join(
            home,
            "Library/HTTPStorages/com.docker.docker",
        ),
        os.path.join(
            home,
            "Library/HTTPStorages/com.docker.docker.binarycookies",
        ),
        os.path.join(home, "Library/Logs/Docker Desktop"),
        os.path.join(
            home,
            "Library/Preferences/com.docker.docker.plist",
        ),
        os.path.join(
            home,
            "Library/Preferences/"
            "com.electron.docker-frontend.plist",
        ),
        os.path.join(
            home,
            "Library/Preferences/"
            "com.electron.dockerdesktop.plist",
        ),
        os.path.join(
            home,
            "Library/Saved Application State/"
            "com.electron.docker-frontend.savedState",
        ),
        os.path.join(
            home,
            "Library/Saved Application State/"
            "com.electron.dockerdesktop.savedState",
        ),
    ]
    for path in user_paths:
        if os.path.lexists(path):
            rm(path)
