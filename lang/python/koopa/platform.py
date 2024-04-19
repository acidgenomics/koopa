"""
Platform-specific variables.
Updated 2024-04-19.
"""

from os.path import abspath, dirname, isdir, join
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


def arch2() -> str:
    """
    Architecture string 2.
    Updated 2023-03-27.
    """
    string = arch()
    if string == "x86_64":
        string = "amd64"
    return string


def koopa_opt_prefix() -> str:
    """
    koopa opt prefix.
    Updated 2023-12-14.
    """
    prefix = join(koopa_prefix(), "opt")
    assert isdir(prefix)
    return prefix


def koopa_prefix() -> str:
    """
    koopa prefix.
    Updated 2024-04-19.
    """
    prefix = abspath(join(dirname(__file__), "../../.."))
    assert isdir(prefix)
    return prefix


def os_id() -> str:
    """
    Platform and architecture-specific identifier.
    Updated 2024-04-19.
    """
    string = system().lower()
    if string == "darwin":
        string = "macos"
    string = string + "-" + arch()
    return string
