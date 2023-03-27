#!/usr/bin/env python3

"""
Solve app dependencies defined in 'app.json' file.
@note Updated 2023-03-27.

@examples
./app-reverse-dependencies.py 'python3.11'
"""

from argparse import ArgumentParser
from json import load
from os.path import abspath, dirname, join


def get_deps(app_name: str, json_data: dict) -> list:
    """
    Get unique dependencies in an ordered list.
    @note Updated 2023-03-27.
    """
    assert app_name in json_data
    deps = []
    if "dependencies" in json_data[app_name]:
        deps = json_data[app_name]["dependencies"]
    out = list(dict.fromkeys(deps))
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
        all_deps = []
        i = 0
        for key in keys:
            all_deps[i] = get_deps(app_name=key, json_data=json_data)
            i += 1
        print(all_deps)
        return True


parser = ArgumentParser()
parser.add_argument("app_name", nargs="?", type=str)
args = parser.parse_args()

_json_file = abspath(join(dirname(__file__), "../../etc/koopa/app.json"))

main(app_name=args.app_name, json_file=_json_file)
