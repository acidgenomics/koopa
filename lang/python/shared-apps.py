#!/usr/bin/env python3

"""
Return supported shared applications defined in 'app.json' file.
@note Updated 2023-03-27.

@examples
./shared-apps.py
"""

from json import load
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


def main(json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-27.
    """
    sys_dict = {}
    sys_dict["arch"] = arch2()
    sys_dict["large"] = large()
    sys_dict["platform"] = platform()
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    for app_name in json_data.keys():
        json = json_data[app_name]
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
        print(app_name)
    return True


_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))

main(json_file=_json_file)
