#!/usr/bin/env python3

"""Prune app binaries.

Examples
--------
$ ./prune-app-binaries.py
"""

from argparse import ArgumentParser, BooleanOptionalAction
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "..", "src"))

from koopa.app import prune_app_binaries

parser = ArgumentParser()
parser.add_argument("--dry-run", action=BooleanOptionalAction)
args = parser.parse_args()


def main(dry_run: bool = False) -> None:
    """Main function."""
    prune_app_binaries(dry_run=dry_run)


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main(dry_run=args.dry_run)
