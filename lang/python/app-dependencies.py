#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
Updated 2023-12-11.

Examples:
./app-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, join
from platform import machine, system
from sys import version_info

parser = ArgumentParser()
parser.add_argument("app_name")
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))


def arch() -> str:
    """
    Architecture string.
    Updated 2023-10-16.
    """
    string = machine()
    if string == "x86_64":
        string = "amd64"
    return string


def flatten(items: list, seqtypes=(list, tuple)) -> list:
    """
    Flatten an arbitrarily nested list.
    Updated 2023-03-25.

    See also:
    - https://stackoverflow.com/a/10824086
    """
    try:
        for i, x in enumerate(items):
            while isinstance(x, seqtypes):
                items[i : i + 1] = x  # noqa: E203
                x = items[i]
    except IndexError:
        pass
    return items


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique build dependencies and dependencies in an ordered list.
    Updated 2023-10-16.

    This makes list unique but keeps order intact, whereas usage of 'set()'
    can rearrange.
    """
    if app_name not in json_data:
        raise NameError("Unsupported app: '" + app_name + "'.")
    sys_dict = {}
    sys_dict["os_id"] = os_id()
    build_deps = []
    deps = []
    if "build_dependencies" in json_data[app_name]:
        build_deps = json_data[app_name]["build_dependencies"]
        if isinstance(build_deps, dict):
            if sys_dict["os_id"] in build_deps.keys():
                build_deps = build_deps[sys_dict["os_id"]]
            else:
                build_deps = build_deps["noarch"]
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
        if isinstance(deps, dict):
            if sys_dict["os_id"] in deps.keys():
                deps = deps[sys_dict["os_id"]]
            else:
                deps = deps["noarch"]
    all_deps = build_deps + deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


def os_id() -> str:
    """
    Platform and architecture-specific identifier.
    Updated 2023-10-16.
    """
    string = platform() + "-" + arch()
    return string


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


def print_apps(app_names: list, json_data: dict) -> bool:
    """
    Print relevant apps.
    Updated 2023-10-16.
    """
    sys_dict = {}
    sys_dict["os_id"] = os_id()
    for val in app_names:
        json = json_data[val]
        keys = json.keys()
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


def main(app_name: str, json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    Updated 2023-10-13.
    """
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    keys = json_data.keys()
    if app_name not in keys:
        raise NameError("Unsupported app: '" + app_name + "'.")
    deps = get_deps(app_name=app_name, json_data=json_data)
    if len(deps) <= 0:
        return True
    i = 0
    lst = []
    lst.append(deps)
    while i <= len(deps):
        lvl1 = []
        for lvl2 in lst[i]:
            if isinstance(lvl2, list):
                for lvl3 in lvl2:
                    lvl4 = get_deps(app_name=lvl3, json_data=json_data)
                    if len(lvl4) > 0:
                        lvl1.append(lvl4)
            else:
                lvl3 = get_deps(app_name=lvl2, json_data=json_data)
                if len(lvl3) > 0:
                    lvl1.append(lvl3)
        if len(lvl1) <= 0:
            break
        lst.append(lvl1)
        i = i + 1
    lst.reverse()
    lst = flatten(lst)
    lst = list(dict.fromkeys(lst))
    print_apps(app_names=lst, json_data=json_data)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(app_name=args.app_name, json_file=_json_file)
