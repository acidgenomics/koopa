"""
koopa module.
Updated 2023-12-11.
"""

from os import walk
from platform import machine


def arch() -> str:
    """
    Architecture string.
    Updated 2023-10-16.
    """
    string = machine()
    if string == "x86_64":
        string = "amd64"
    return string


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
