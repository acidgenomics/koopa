"""Operative system (platform)-specific variables."""

from os.path import abspath, dirname, isdir, join
from platform import machine, system


def arch() -> str:
    """Architecture string."""
    string = machine()
    if string == "x86_64":
        string = "amd64"
    return string


def arch2() -> str:
    """Architecture string 2."""
    string = arch()
    if string == "x86_64":
        string = "amd64"
    return string


def koopa_app_prefix() -> str:
    """Koopa app prefix."""
    prefix = join(koopa_prefix(), "app")
    return prefix


def koopa_opt_prefix() -> str:
    """Koopa opt prefix."""
    prefix = join(koopa_prefix(), "opt")
    return prefix


def koopa_prefix() -> str:
    """Koopa prefix."""
    prefix = abspath(join(dirname(__file__), "../../.."))
    assert isdir(prefix)
    return prefix


def os_id() -> str:
    """Platform and architecture-specific identifier."""
    string = system().lower()
    if string == "darwin":
        string = "macos"
    string = string + "-" + arch()
    return string
