#!/usr/bin/env python3

"""
Parse conda JSON metadata for files to link in 'bin'.
Updated 2023-12-14.

Examples:
./conda-bin-names.py \
    /opt/koopa/opt/salmon/libexec/conda-meta/salmon-*.json
"""

from argparse import ArgumentParser
from json import load
from re import compile as re_compile
from sys import version_info

parser = ArgumentParser()
parser.add_argument("json_file")
args = parser.parse_args()


def main(json_file: str) -> bool:
    """
    Parse conda JSON metadata for files to link in 'bin'.
    Updated 2023-05-11.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    keys = json_data.keys()
    if "files" not in keys:
        raise ValueError("Invalid JSON: '" + json_file + "'.")
    file_list = json_data["files"]
    bin_files = []
    pattern = re_compile(r"^bin/([^/]+)$")
    for file in file_list:
        match = pattern.match(file)
        if match:
            bin_file = match.group(1)
            bin_files.append(bin_file)
    if any(bin_files):
        for bin_file in bin_files:
            print(bin_file)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(json_file=args.json_file)
