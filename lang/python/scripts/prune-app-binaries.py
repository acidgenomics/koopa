#!/usr/bin/env python3

"""
Prune app binaries.
Updated 2024-05-16.

Examples:
./prune-app-binaries.py
"""

from argparse import ArgumentParser, BooleanOptionalAction
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), ".."))

from koopa.app import prune_app_binaries

parser = ArgumentParser()
parser.add_argument("--dry-run", action=BooleanOptionalAction)
args = parser.parse_args()


def main(dry_run=False) -> None:
    """
    Main function.
    Updated 2024-05-16.
    """
    prune_app_binaries(dry_run=dry_run)
    return None


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(dry_run=args.dry_run)
