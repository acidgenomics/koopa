#!/usr/bin/env python3

# FIXME Need to rework platform specific handling.

"""
Return supported shared applications defined in 'app.json' file.
@note Updated 2023-10-13.

@examples
./shared-apps.py
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, isdir, join
from platform import machine, system
from sys import version_info

parser = ArgumentParser()
parser.add_argument(
    "--mode", choices=["all-supported", "default-only"], required=False
)
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


def koopa_opt_prefix() -> str:
    """
    koopa opt prefix.
    @note Updated 2023-05-01.
    """
    prefix = abspath(join(koopa_prefix(), "opt"))
    return prefix


def koopa_prefix() -> str:
    """
    koopa prefix.
    @note Updated 2023-05-01.
    """
    prefix = abspath(join(dirname(__file__), "../.."))
    return prefix


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


def print_apps(app_names: list, json_data: dict, mode: str) -> bool:
    """
    Print relevant apps.
    @note Updated 2023-10-13.
    """
    sys_dict = {}
    sys_dict["arch"] = arch2()
    sys_dict["opt_prefix"] = koopa_opt_prefix()
    sys_dict["platform"] = platform()
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
        if "arch" in keys:
            if json["arch"] != sys_dict["arch"]:
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


def main(json_file: str, mode: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-10-13.
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
