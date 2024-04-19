"""
Shell parsing functions that rely upon subprocess.
Updated 2024-04-19.
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
    """
    if not which("fd"):
        raise RuntimeError("fd is not installed.")
    if not isdir(prefix):
        raise ValueError("Not directory: '" + prefix + "'.")
    prefix = realpath(expanduser(prefix), strict=True)
    print("Finding files in '" + prefix + "'.", file=stderr)
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
