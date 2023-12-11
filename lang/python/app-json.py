#!/usr/bin/env python3

"""
Parse koopa 'app.json' file.
@note Updated 2023-12-11.

@examples
./app-json.py \
    --app-name='coreutils' \
    --key='bin'
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, join
from sys import version_info

parser = ArgumentParser()
parser.add_argument("--app-name", required=True)
parser.add_argument("--key", required=True)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))


def main(json_file: str, app_name: str, key: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-27.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    keys = json_data.keys()
    if app_name not in keys:
        raise NameError("Unsupported app: '" + app_name + "'.")
    app_dict = json_data[app_name]
    if key not in app_dict.keys():
        raise ValueError("Invalid key: '" + key + "'.")
    value = app_dict[key]
    if isinstance(value, list):
        for i in value:
            print(i)
    else:
        print(value)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(json_file=_json_file, app_name=args.app_name, key=args.key)
