#!/usr/bin/env python3

"""
Parse JSON.
Updated 2022-08-22.
"""

import argparse
import json


def parse_bin_json(file, app_name):
    """
    Parse the koopa 'bin.json' file.
    Updated 2022-08-22.
    """
    with open(file, encoding="utf-8") as con:
        data = json.load(con)
        keys = data.keys()
        if app_name not in keys:
            return False
        for val in data[app_name]:
            print(val)
        return True


parser = argparse.ArgumentParser()
parser.add_argument("file")
parser.add_argument("app_name")
args = parser.parse_args()

parse_bin_json(args.file, args.app_name)
