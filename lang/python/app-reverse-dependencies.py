#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
Updated 2023-12-11.

Examples:
./app-reverse-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, isdir, join
from platform import machine, system
from sys import version_info

parser = ArgumentParser()
parser.add_argument("--mode", choices=["all-supported", "default-only"], required=False)
parser.add_argument("app_name")
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))


def arch() -> str:
    """
    Architecture string.
    Updated 2023-03-27.
    """
    string = machine()
    return string


def arch2() -> str:
    """
    Architecture string 2.
    Updated 2023-03-27.
    """
    string = arch()
    if string == "x86_64":
        string = "amd64"
    return string


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique dependencies in an ordered list.
    Updated 2023-05-11.
    """
    if app_name not in json_data:
        raise NameError("Unsupported app: '" + app_name + "'.")
    deps = []
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
    out = list(dict.fromkeys(deps))
    return out


def koopa_opt_prefix() -> str:
    """
    koopa opt prefix.
    Updated 2023-05-01.
    """
    prefix = abspath(join(koopa_prefix(), "opt"))
    return prefix


def koopa_prefix() -> str:
    """
    koopa prefix.
    Updated 2023-05-01.
    """
    prefix = abspath(join(dirname(__file__), "../.."))
    return prefix


def platform() -> str:
    """
    Platform string.
    Updated 2023-03-27.
    """
    string = system()
    string = string.lower()
    if string == "darwin":
        string = "macos"
    return string


def print_apps(app_names: list, json_data: dict, mode: str) -> bool:
    """
    Print relevant apps.
    Updated 2023-10-16.
    """
    sys_dict = {}
    sys_dict["arch"] = arch2()
    sys_dict["opt_prefix"] = koopa_opt_prefix()
    for val in app_names:
        if mode != "default-only":
            if isdir(join(sys_dict["opt_prefix"], val)):
                print(val)
                continue
        json = json_data[val]
        keys = json.keys()
        if "default" in keys and mode != "all-supported":
            if not json["default"]:
                continue
        if "removed" in keys:
            if json["removed"]:
                continue
        if "supported" in keys:
            if sys_dict["os_id"] in json["supported"].keys():
                if not json["supported"][sys_dict["os_id"]]:
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


def main(app_name: str, json_file: str, mode: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    Updated 2023-10-13.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    keys = list(json_data.keys())
    if app_name not in keys:
        raise NameError("Unsupported app: '" + app_name + "'.")
    all_deps = []
    for key in keys:
        key_deps = get_deps(app_name=key, json_data=json_data)
        all_deps.append(key_deps)
    deps = []
    i = 0
    while i < len(all_deps):
        if app_name in all_deps[i]:
            deps.append(keys[i])
        i += 1
    if len(deps) <= 0:
        return True
    print_apps(app_names=deps, json_data=json_data, mode=mode)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(app_name=args.app_name, json_file=_json_file, mode=args.mode)
