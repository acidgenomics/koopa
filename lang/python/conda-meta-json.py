#!/usr/bin/env python3

"""
Parse conda JSON metadata for files to link in bin.
@note Updated 2023-03-25.

@examples
./conda-meta-json.py \
    /opt/koopa/opt/salmon/libexec/conda-meta/salmon-*.json
"""

from argparse import ArgumentParser
from json import load
from re import compile as re_compile


def main(json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-25.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
        keys = json_data.keys()
        assert "files" in keys
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


parser = ArgumentParser()
parser.add_argument("json_file", nargs="?", type=str)
args = parser.parse_args()

main(json_file=args.json_file)
