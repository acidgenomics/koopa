#!/usr/bin/env python3

"""
Return shared apps defined in 'app.json' file.
Updated 2024-05-05.

Examples:
./shared-apps.py
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), ".."))

from koopa.cli import print_shared_apps

parser = ArgumentParser()
parser.add_argument(
    "--mode",
    choices=["all", "default"],
    default="default",
    required=False,
)
args = parser.parse_args()


def main(mode: str) -> None:
    """
    Main function.
    Updated 2023-12-14.
    """
    print_shared_apps(mode=mode)
    return None


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(mode=args.mode)
