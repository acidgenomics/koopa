#!/usr/bin/env python3

"""
Parse koopa 'app.json' file.
Updated 2024-05-05.

Examples:
./app-json.py \
    --app-name='coreutils' \
    --key='bin'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

parser = ArgumentParser()
parser.add_argument("--name", required=True)
parser.add_argument("--key", required=True)
args = parser.parse_args()

path.insert(0, join(dirname(__file__), ".."))

from koopa.cli import print_app_json


def main(name: str, key: str) -> None:
    """
    Main function.
    Updated 2023-12-14.
    """
    print_app_json(name=name, key=key)
    return None


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(name=args.name, key=args.key)
