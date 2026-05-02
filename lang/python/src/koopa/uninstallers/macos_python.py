"""Uninstall Python framework on macOS."""

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
    """Uninstall Python framework on macOS."""
    framework = "/Library/Frameworks/Python.framework"
    if not os.path.exists(framework):
        return
    # Exact system paths (require sudo).
    system_paths = [
        "/Library/Frameworks/Python.framework",
        "/usr/local/bin/2to3",
        "/usr/local/bin/idle3",
        "/usr/local/bin/pip3",
        "/usr/local/bin/pydoc3",
        "/usr/local/bin/python",
        "/usr/local/bin/python3",
        "/usr/local/bin/python3-config",
    ]
    for path in system_paths:
        if os.path.lexists(path):
            rm(path, sudo=True)
    # Glob system paths (require sudo).
    system_patterns = [
        "/Applications/Python*",
        "/usr/local/bin/2to3-*",
        "/usr/local/bin/idle3.*",
        "/usr/local/bin/pip3.*",
        "/usr/local/bin/pydoc3.*",
        "/usr/local/bin/python3-*",
        "/usr/local/bin/python3.*",
        "/usr/local/lib/python*",
    ]
    for pattern in system_patterns:
        for path in glob.glob(pattern):
            rm(path, sudo=True)
