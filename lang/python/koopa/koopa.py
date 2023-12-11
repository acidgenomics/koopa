"""
koopa module.
Updated 2023-12-11.
"""

from os import walk
from platform import machine, system


def arch() -> str:
    """
    Architecture string.
    Updated 2023-10-16.
    """
    string = machine()
    if string == "x86_64":
        string = "amd64"
    return string


def flatten(items: list, seqtypes=(list, tuple)) -> list:
    """
    Flatten an arbitrarily nested list.
    Updated 2023-03-25.

    See also:
    - https://stackoverflow.com/a/10824086
    """
    try:
        for i, x in enumerate(items):
            while isinstance(x, seqtypes):
                items[i : i + 1] = x  # noqa: E203
                x = items[i]
    except IndexError:
        pass
    return items


def list_subdirs(path: str) -> list:
    """
    List subdirectories in a directory.
    Updated 2023-12-11.

    See also:
    - https://stackoverflow.com/questions/141291/
    """
    lst = next(walk(path))[1]
    lst = lst.sort()
    return lst


def os_id() -> str:
    """
    Platform and architecture-specific identifier.
    Updated 2023-10-16.
    """
    string = platform() + "-" + arch()
    return string


def platform() -> str:
    """
    Platform string.
    Updated 2023-03-27.
    """
    string = system()
    string = string.lower()
    if string == "darwin":
        string = "macos"
    return string
