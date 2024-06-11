#!/usr/bin/env python3

"""
Check system integrity, including outdated apps.
Updated 2024-05-28.

Examples:
./check-system.py
"""

from os.path import dirname, join
from sys import exit, path, version_info

path.insert(0, join(dirname(__file__), ".."))

from koopa.check import check_installed_apps


def main() -> None:
    """
    Main function.
    Updated 2024-05-28.
    """
    ok = check_installed_apps()
    if not ok:
        exit(1)
    return None


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main()
