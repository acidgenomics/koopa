#!/usr/bin/env python3

"""Check system integrity, including outdated apps.

Examples
--------
$ ./check-system.py
"""

from os.path import dirname, join
from sys import exit, path, version_info

path.insert(0, join(dirname(__file__), "../src"))

from koopa.check import check_bootstrap_version, check_installed_apps


def main() -> None:
    """Main function."""
    ok = True
    if not check_bootstrap_version():
        ok = False
    if not check_installed_apps():
        ok = False
    if not ok:
        exit(1)


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main()
