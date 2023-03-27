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
                items[i : i + 1] = x  # noqa: E203
                x = items[i]
    except IndexError:
        pass
    return items


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique build dependencies and dependencies in an ordered list.
    @note Updated 2023-03-25.

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
    out = build_deps + deps
    out = list(dict.fromkeys(out))
    return out


def main(app_name: str, json_file: str) -> bool:
    """
    Parse the koopa 'app.json' file for defined values.
    @note Updated 2023-03-27.
    """
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
    for val in lst:
        print(val)
    return True


parser = ArgumentParser()
parser.add_argument("app_name", nargs="?", type=str)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))

main(app_name=args.app_name, json_file=_json_file)
