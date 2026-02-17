"""PATH manipulation functions.

Converted from POSIX shell functions: add-to-path-string-end,
add-to-path-string-start, remove-from-path-string, etc.
"""

from __future__ import annotations

import os


def add_to_path_string_end(path_string: str, directory: str) -> str:
    """Add a directory to the end of a PATH-like string."""
    dirs = [d for d in path_string.split(":") if d]
    if directory not in dirs:
        dirs.append(directory)
    return ":".join(dirs)


def add_to_path_string_start(path_string: str, directory: str) -> str:
    """Add a directory to the start of a PATH-like string."""
    dirs = [d for d in path_string.split(":") if d]
    if directory in dirs:
        dirs.remove(directory)
    dirs.insert(0, directory)
    return ":".join(dirs)


def remove_from_path_string(path_string: str, directory: str) -> str:
    """Remove a directory from a PATH-like string."""
    dirs = [d for d in path_string.split(":") if d and d != directory]
    return ":".join(dirs)


def add_to_path_end(directory: str) -> None:
    """Add a directory to the end of PATH."""
    os.environ["PATH"] = add_to_path_string_end(
        os.environ.get("PATH", ""),
        directory,
    )


def add_to_path_start(directory: str) -> None:
    """Add a directory to the start of PATH."""
    os.environ["PATH"] = add_to_path_string_start(
        os.environ.get("PATH", ""),
        directory,
    )


def remove_from_path(directory: str) -> None:
    """Remove a directory from PATH."""
    os.environ["PATH"] = remove_from_path_string(
        os.environ.get("PATH", ""),
        directory,
    )


def add_to_manpath_end(directory: str) -> None:
    """Add a directory to the end of MANPATH."""
    os.environ["MANPATH"] = add_to_path_string_end(
        os.environ.get("MANPATH", ""),
        directory,
    )


def add_to_manpath_start(directory: str) -> None:
    """Add a directory to the start of MANPATH."""
    os.environ["MANPATH"] = add_to_path_string_start(
        os.environ.get("MANPATH", ""),
        directory,
    )


def add_to_pkg_config_path(directory: str) -> None:
    """Add a directory to PKG_CONFIG_PATH."""
    os.environ["PKG_CONFIG_PATH"] = add_to_path_string_start(
        os.environ.get("PKG_CONFIG_PATH", ""),
        directory,
    )


def list_path_priority() -> list[str]:
    """List PATH directories in priority order."""
    return [d for d in os.environ.get("PATH", "").split(":") if d]


def list_path_priority_unique() -> list[str]:
    """List unique PATH directories in priority order."""
    seen: set[str] = set()
    result: list[str] = []
    for d in list_path_priority():
        if d not in seen:
            seen.add(d)
            result.append(d)
    return result
