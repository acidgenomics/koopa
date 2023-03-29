#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
@note Updated 2023-03-27.

@examples
./app-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
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


def flatten(items, seqtypes=(list, tuple)):
    """
    Flatten an arbitrarily nested list.
    @note Updated 2023-03-25.

    @seealso
    - https://stackoverflow.com/a/10824086
    """
    try:
        for i, x in enumerate(items):
            while isinstance(x, seqtypes):
                items[i: i + 1] = x  # noqa: E203
                x = items[i]
    except IndexError:
        pass
    return items


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique build dependencies and dependencies in an ordered list.
    @note Updated 2023-03-27.

    This makes list unique but keeps order intact, whereas usage of 'set()'
    can rearrange.
    """
    assert app_name in json_data
    build_deps = []
    deps = []
    if "build_dependencies" in json_data[app_name]:
        build_deps = json_data[app_name]["build_dependencies"]
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
    all_deps = build_deps + deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


# FIXME This should return true if KOOPA_BUILDER environment variable is defined.

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


def main(app_name: str, json_file: str) -> bool:
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
    keys = json_data.keys()
    assert app_name in keys
    deps = get_deps(app_name=app_name, json_data=json_data)
    if len(deps) <= 0:
        return True
    i = 0
    lst = []
    lst.append(deps)
    while i < len(deps):
        lvl1 = []
        for lvl2 in lst[i]:
            if isinstance(lvl2, list):
                for lvl3 in lvl2:
                    lvl4 = get_deps(
                        app_name=lvl3, json_data=json_data)
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
    for val in lst:
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


parser = ArgumentParser()
parser.add_argument("app_name", nargs="?", type=str)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))

main(app_name=args.app_name, json_file=_json_file)
