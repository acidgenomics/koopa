"""
Find functions that return subprocess output.
Updated 2024-04-14.
"""

from multiprocessing import cpu_count
from os.path import expanduser, isdir, realpath
from shutil import which
from subprocess import run
from sys import stderr


def fd_find(prefix: str, pattern: str) -> list:
    """
    Find files quickly using fd.
    Updated 2023-05-25.

    Uses regular expressions for pattern matching.
    Does not return sorted.

    Examples:
    >>> fd_find(prefix="/opt/koopa/lang/python", pattern="\\.py$")
    """
    if not which("fd"):
        raise RuntimeError("fd is not installed.")
    if not isdir(prefix):
        raise ValueError(f"Not directory: {prefix!r}.")
    prefix = realpath(expanduser(prefix), strict=True)
    print(f"Finding files in {prefix!r}.", file=stderr)
    threads = cpu_count()
    output = run(
        args=[
            "fd",
            "--absolute-path",
            "--base-directory",
            str(prefix),
            "--regex",
            "--type",
            "f",
            "--threads",
            str(threads),
            str(pattern),
        ],
        capture_output=True,
        check=True,
        text=True,
    )
    lst = output.stdout.split("\n")[:-1]
    return lst
