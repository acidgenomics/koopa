#!/usr/bin/env python3

"""Return shared apps defined in 'app.json' file.

Examples
--------
$ ./shared-apps.py
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "..", "src"))

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
    """Main function."""
    print_shared_apps(mode=mode)


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main(mode=args.mode)
