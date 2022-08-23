#!/usr/bin/env python3

"""
Parse koopa 'app.json' file.
@note Updated 2022-08-23.

@examples
./parse-app-json.py \
    --app-name='coreutils' \
    --key='bin'
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, join


def main(json_file, app_name, key):
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2022-08-23.
    """
    with open(json_file, encoding="utf-8") as con:
        data = load(con)
        keys = data.keys()
        if app_name not in keys:
            return False
        app_dict = data[app_name]
        if key not in app_dict.keys():
            return False
        for val in app_dict[key]:
            print(val)
        return True


parser = ArgumentParser()
parser.add_argument("--app-name", required=True, type=str)
parser.add_argument("--key", required=True, type=str)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../include/app.json"))

main(json_file=_json_file, app_name=args.app_name, key=args.key)
