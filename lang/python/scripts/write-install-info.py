#!/usr/bin/env python3

"""Write install metadata JSON file.

Examples
--------
$ ./write-install-info.py '/path/to/.install/info.json' 'curl' '8.20.0'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "../src"))

from koopa.install_info import write_install_info

parser = ArgumentParser()
parser.add_argument("output_file")
parser.add_argument("name")
parser.add_argument("version")
args = parser.parse_args()


def main(output_file: str, name: str, version: str) -> None:
    """Main function."""
    write_install_info(
        output_file=output_file,
        name=name,
        version=version,
    )


if __name__ == "__main__":
    if not version_info >= (3, 11):
        raise RuntimeError("Unsupported Python version.")
    main(
        output_file=args.output_file,
        name=args.name,
        version=args.version,
    )
