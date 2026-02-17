"""XDG Base Directory Specification functions.

Converted from POSIX shell functions: xdg-cache-home, xdg-config-dirs,
xdg-config-home, xdg-data-dirs, xdg-data-home, xdg-local-home, xdg-state-home.
"""

from __future__ import annotations

import os


def xdg_cache_home() -> str:
    """Return XDG_CACHE_HOME."""
    return os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache"))


def xdg_config_dirs() -> list[str]:
    """Return XDG_CONFIG_DIRS as a list."""
    dirs = os.environ.get("XDG_CONFIG_DIRS", "/etc/xdg")
    return dirs.split(":")


def xdg_config_home() -> str:
    """Return XDG_CONFIG_HOME."""
    return os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))


def xdg_data_dirs() -> list[str]:
    """Return XDG_DATA_DIRS as a list."""
    dirs = os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share")
    return dirs.split(":")


def xdg_data_home() -> str:
    """Return XDG_DATA_HOME."""
    return os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share"))


def xdg_local_home() -> str:
    """Return XDG local home (~/.local)."""
    return os.path.expanduser("~/.local")


def xdg_state_home() -> str:
    """Return XDG_STATE_HOME."""
    return os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state"))
