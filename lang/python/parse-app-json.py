#!/usr/bin/env python3

"""
Parse koopa 'app.json' file.
@note Updated 2022-08-22.

@examples
./parse-app-json.py '/opt/koopa/include/app.json' 'coreutils' 'bin'
"""

import argparse
import json


def parse_app_json(file, app_name, key):
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2022-08-22.
    """
    with open(file, encoding="utf-8") as con:
        data = json.load(con)
        keys = data.keys()
        if app_name not in keys:
            return False
        app_dict = data[app_name]
        if key not in app_dict.keys():
            return False
        for val in app_dict[key]:
            print(val)
        return True


parser = argparse.ArgumentParser()
parser.add_argument("file")
parser.add_argument("app_name")
parser.add_argument("key")
args = parser.parse_args()

parse_app_json(file=args.file, app_name=args.app_name, key=args.key)
