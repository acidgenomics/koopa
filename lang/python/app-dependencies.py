#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
@note Updated 2023-10-13.

@examples
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
    @note Updated 2023-10-13.

    This makes list unique but keeps order intact, whereas usage of 'set()'
    can rearrange.
    """
    if app_name not in json_data:
        raise NameError("Unsupported app: '" + app_name + "'.")
    build_deps = []
    deps = []
    os_id = os_string()
    if "supported" in json_data[app_name]:
        supported = json_data[app_name]["supported"]
        if os_id in supported.keys():
            if not supported[os_id]:
                return []
    if "build_dependencies" in json_data[app_name]:
        build_deps = json_data[app_name]["build_dependencies"]
        if isinstance(build_deps, dict):
            if os_id in build_deps.keys():
                build_deps = build_deps[os_id]
            else:
                build_deps = build_deps["noarch"]
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
        if isinstance(deps, dict):
            if os_id in deps.keys():
                deps = deps[os_id]
            else:
                deps = deps["noarch"]
    all_deps = build_deps + deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


def os_string() -> str:
    """
    Platform and architecture-specific identifier.
    @note Updated 2023-10-13.
    """
    string = platform() + "-" + arch2()
    return string


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
    @note Updated 2023-10-13.
    """
    sys_dict = {}
    sys_dict["arch"] = arch2()
    sys_dict["platform"] = platform()
    for val in app_names:
        json = json_data[val]
        keys = json.keys()
        # FIXME Need to rework this step.
        if "supported" in keys:
            raise NameError(val)
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


def main(app_name: str, json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-10-13.
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
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(app_name=args.app_name, json_file=_json_file)
