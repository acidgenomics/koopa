#!/usr/bin/env python3

"""
Check system integrity, including outdated apps.
Updated 2024-05-28.

Examples:
./check-system.py
"""

from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), ".."))

from koopa.cli import check_system


def main() -> None:
    """
    Main function.
    Updated 2024-05-28.
    """
    check_system()
    return None


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main()
