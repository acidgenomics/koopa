#!/usr/bin/env python3

"""Find installed apps with stale runtime dependencies.

Given a list of app names being reinstalled, prints any currently installed
apps that depend on them at runtime and may need to be rebuilt.

Examples
--------
$ ./stale-revdeps.py 'curl' 'openssl'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "../src"))

from koopa.cli import print_stale_revdeps

parser = ArgumentParser()
parser.add_argument("names", nargs="+")
args = parser.parse_args()


def main(names: list) -> None:
    """Main function."""
    print_stale_revdeps(names=names)


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main(names=args.names)
