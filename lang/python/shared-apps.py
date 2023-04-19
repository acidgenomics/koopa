#!/usr/bin/env python3

# FIXME This needs to pick up apps that are already installed.

"""
Return supported shared applications defined in 'app.json' file.
@note Updated 2023-03-29.

@examples
./shared-apps.py
"""

from json import load
from os import getenv
from os.path import abspath, dirname, join
from platform import machine, system
from shutil import disk_usage


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


def large() -> bool:
    """
    Is the current machine a large instance?
    @note Updated 2023-03-27.
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
    @note Updated 2023-03-29.
    """
    sys_dict = {}
    sys_dict["arch"] = arch2()
    sys_dict["large"] = large()
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
            if json["large"] and not sys_dict["large"]:
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


def main(json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-29.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    app_names = json_data.keys()
    print_apps(app_names=app_names, json_data=json_data)
    return True


_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))

main(json_file=_json_file)
