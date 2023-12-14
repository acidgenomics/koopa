#!/usr/bin/env python3

"""
Solve app reverse dependencies defined in 'app.json' file.
Updated 2023-12-14.

Examples:
./app-reverse-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "koopa"))

from koopa import print_app_revdeps, snake_case

parser = ArgumentParser()
parser.add_argument(
    "--mode",
    choices=["all-supported", "default-only"],
    default="default-only",
    required=False,
)
parser.add_argument("app_name")
args = parser.parse_args()
args.mode = snake_case(args.mode)


def main(name: str, mode: str) -> bool:
    """
    Main function.
    Updated 2023-12-14.
    """
    print_app_revdeps(name=name, mode=mode)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(name=args.name, mode=args.mode)
