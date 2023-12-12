#!/usr/bin/env python3

"""
Return supported shared applications defined in 'app.json' file.
Updated 2023-12-11.

Examples:
./shared-apps.py
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, isdir, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "koopa"))

from koopa import koopa_opt_prefix, os_id

parser = ArgumentParser()
parser.add_argument(
    "--mode", choices=["all-supported", "default-only"], required=False
)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))


def print_apps(app_names: list, json_data: dict, mode: str) -> bool:
    """
    Print relevant apps.
    Updated 2023-10-16.
    """
    sys_dict = {}
    sys_dict["opt_prefix"] = koopa_opt_prefix()
    sys_dict["os_id"] = os_id()
    for val in app_names:
        if mode != "default-only":
            if isdir(join(sys_dict["opt_prefix"], val)):
                print(val)
                continue
        json = json_data[val]
        keys = json.keys()
        if "supported" in json:
            if sys_dict["os_id"] in json["supported"].keys():
                if not json["supported"][sys_dict["os_id"]]:
                    continue
        if "default" in keys and mode != "all-supported":
            if not json["default"]:
                continue
        if "removed" in keys:
            if json["removed"]:
                continue
        if "private" in keys:
            if json["private"]:
                continue
        if "system" in keys:
            if json["system"]:
                continue
        if "user" in keys:
            if json["user"]:
                continue
        print(val)
    return True


def main(json_file: str, mode: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    Updated 2023-10-13.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    app_names = json_data.keys()
    print_apps(app_names=app_names, json_data=json_data, mode=mode)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(json_file=_json_file, mode=args.mode)
