"""
koopa module.
Updated 2023-12-14.
"""

from json import load
from os import walk
from os.path import abspath, dirname, isdir, isfile, join
from platform import machine, system


def app_json_data() -> list:
    """
    Koopa app.json data.
    Updated 2023-12-14.
    """
    json_file = app_json_file()
    with open(json_file, encoding="utf-8") as con:
        json_data = load(con)
    return json_data


def app_json_file() -> str:
    """
    Koopa app.json file.
    Updated 2023-12-14.
    """
    file = join(koopa_prefix(), "etc/koopa/app.json")
    assert isfile(file)
    return file


def arch() -> str:
    """
    Architecture string.
    Updated 2023-10-16.
    """
    string = machine()
    if string == "x86_64":
        string = "amd64"
    return string


def arch2() -> str:
    """
    Architecture string 2.
    Updated 2023-03-27.
    """
    string = arch()
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
                items[i : i + 1] = x
                x = items[i]
    except IndexError:
        pass
    return items


def koopa_opt_prefix() -> str:
    """
    koopa opt prefix.
    Updated 2023-12-14.
    """
    prefix = join(koopa_prefix(), "opt")
    assert isdir(prefix)
    return prefix


def koopa_prefix() -> str:
    """
    koopa prefix.
    Updated 2023-12-14.
    """
    prefix = abspath(join(dirname(__file__), "../../.."))
    assert isdir(prefix)
    return prefix


def list_subdirs(path: str) -> list:
    """
    List subdirectories in a directory.
    Updated 2023-12-11.

    See also:
    - https://stackoverflow.com/questions/141291/
    """
    lst = next(walk(path))[1]
    lst = lst.sort()
    return lst


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


def print_list(obj) -> bool:
    """
    Loop across a list and print elements to console.
    Updated 2023-12-14.
    """
    for val in obj:
        print(val)
    return True


def print_shared_apps(mode: str) -> bool:
    """
    Print shared apps.
    Updated 2023-12-14.
    """
    lst = shared_apps(mode=mode)
    print_list(lst)
    return True


# FIXME How to set option to pick between two settings here?
# Like match.arg in R.

# FIXME Need to rework the mode argparse here.

def shared_apps(mode = ["all_supported", "default_only"]) -> list:
    """
    Return names of shared apps.
    Updated 2023-12-14.
    """
    sys_dict = {}
    sys_dict["opt_prefix"] = koopa_opt_prefix()
    sys_dict["os_id"] = os_id()
    json_data = app_json_data()
    app_names = json_data.keys()
    # FIXME Need to assign these into a list and return the list instead.
    # FIXME Need to rework mode to use underscores here.
    for val in app_names:
        if mode != "default_only":
            if isdir(join(sys_dict["opt_prefix"], val)):
                print(val)
                continue
        json = json_data[val]
        keys = json.keys()
        if "supported" in json:
            if sys_dict["os_id"] in json["supported"].keys():
                if not json["supported"][sys_dict["os_id"]]:
                    continue
        if "default" in keys and mode != "all_supported":
            if not json["default"]:
                continue
        if "removed" in keys:
            if json["removed"]:
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
