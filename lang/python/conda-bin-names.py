#!/usr/bin/env python3

"""
Parse conda JSON metadata for files to link in 'bin'.
Updated 2023-12-14.

Examples:
./conda-bin-names.py \
    /opt/koopa/opt/star/libexec/conda-meta/star-*.json
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

parser = ArgumentParser()
parser.add_argument("json_file")
args = parser.parse_args()

path.insert(0, join(dirname(__file__), "koopa"))

from koopa import print_conda_bin_names


def main(json_file: str) -> None:
    """
    Main function.
    Updated 2023-12-14.
    """
    print_conda_bin_names(json_file=json_file)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(json_file=args.json_file)
