#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
@note Updated 2023-10-03.

@examples
./app-reverse-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from json import load
from os import getenv
from os.path import abspath, dirname, join
from platform import machine, system
from shutil import disk_usage
from sys import version_info

parser = ArgumentParser()
parser.add_argument("app_name")
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))


def arch() -> str:
    """
    Architecture string.
    @note Updated 2023-03-27.
    """
    string = machine()
    return string


def arch2() -> str:
    """
    Architecture string 2.
    @note Updated 2023-03-27.
    """
    string = arch()
    if string == "x86_64":
        string = "amd64"
    return string


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique dependencies in an ordered list.
    @note Updated 2023-05-11.
    """
    if app_name not in json_data:
        raise NameError("Unsupported app: '" + app_name + "'.")
    deps = []
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
    out = list(dict.fromkeys(deps))
    return out


def large() -> bool:
    """
    Is the current machine a large instance?
    @note Updated 2023-03-29.
    """
    if getenv("KOOPA_BUILDER") == "1":
        return True
    usage = disk_usage(path="/")
    lgl = usage.total >= 400000000000
    return lgl


def platform() -> str:
    """
    Platform string.
    @note Updated 2023-03-27.
    """
    string = system()
    string = string.lower()
    if string == "darwin":
        string = "macos"
    return string


def print_apps(app_names: list, json_data: dict) -> bool:
    """
    Print relevant apps.
    @note Updated 2023-10-03.
    """
    sys_bool_dict = {}
    sys_bool_dict["large"] = large()
    sys_dict = {}
    sys_dict["arch"] = arch2()
    sys_dict["platform"] = platform()
    for val in app_names:
        json = json_data[val]
        keys = json.keys()
        if "arch" in keys:
            if json["arch"] != sys_dict["arch"]:
                continue
        if "enabled" in keys:
            if not json["enabled"]:
                continue
        if "large" in keys:
            if json["large"] and not sys_bool_dict["large"]:
                continue
        if "platform" in keys:
            if json["platform"] != sys_dict["platform"]:
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


def main(app_name: str, json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-05-11.
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
    print_apps(app_names=deps, json_data=json_data)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(app_name=args.app_name, json_file=_json_file)
