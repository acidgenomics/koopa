#!/usr/bin/env python3

"""Solve app dependencies defined in 'app.json' file.

Examples
--------
$ ./app-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import exit, path, stderr, version_info

path.insert(0, join(dirname(__file__), "../src"))

from koopa.cli import print_app_deps

parser = ArgumentParser()
parser.add_argument("name")
args = parser.parse_args()


def main(name: str) -> None:
    """Main function."""
    try:
        print_app_deps(name)
    except NameError as e:
        print(f"ERROR: {e}", file=stderr)
        exit(1)


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main(name=args.name)
