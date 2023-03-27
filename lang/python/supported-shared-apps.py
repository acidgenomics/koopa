#!/usr/bin/env python3

"""
Return supported shared applications defined in 'app.json' file.
@note Updated 2023-03-27.

@examples
./supported-shared-apps.py
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
    str = machine()
    return str


def arch2() -> str:
    """
    Architecture string 2.
    @note Updated 2023-03-27.
    """
    str = arch()
    match str:
        case "x86_64":
            str = "amd64"
    return str


def large() -> bool:
    du = disk_usage(path="/")
    bool = du.total >= 400000000000
    return bool


def platform() -> str:
    """
    Platform string.
    @note Updated 2023-03-27.
    """
    str = system()
    str = str.lower()
    match str:
        case "darwin":
            str = "macos"
    return str


# FIXME Need to define large in the dict.

def main(json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-27.
    """
    dd = dict()
    dd["arch"] = arch2()
    dd["large"] = large()
    dd["platform"] = platform()
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    for app_name in json_data.keys():
        json = json_data[app_name]
        keys = json.keys()
        if "arch" in keys:
            if json["arch"] != dd["arch"]:
                continue
        if "check" in keys:
            if not json["check"]:
                continue
        if "large" in keys:
            if json["large"] and not dd["large"]:
                continue
        if "platform" in keys:
            if json["platform"] != dd["platform"]:
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
