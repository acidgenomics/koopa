#!/usr/bin/env python3

"""Solve app dependencies defined in 'app.json' file.

Examples
--------
$ ./app-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), ".."))

from koopa.cli import print_app_deps

parser = ArgumentParser()
parser.add_argument("name")
args = parser.parse_args()


def main(name: str) -> None:
    """Main function."""
    print_app_deps(name)


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main(name=args.name)
