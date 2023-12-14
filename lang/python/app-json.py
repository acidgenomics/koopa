#!/usr/bin/env python3

"""
Parse koopa 'app.json' file.
Updated 2023-12-11.

Examples:
./app-json.py \
    --app-name='coreutils' \
    --key='bin'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

parser = ArgumentParser()
parser.add_argument("--app-name", required=True)
parser.add_argument("--key", required=True)
args = parser.parse_args()

path.insert(0, join(dirname(__file__), "koopa"))

from koopa import print_app_json


def main(app_name: str, key: str) -> None:
    """
    Main function.
    Updated 2023-12-14.
    """
    print_app_json(app_name=app_name, key=key)
    return None


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(app_name=args.app_name, key=args.key)
