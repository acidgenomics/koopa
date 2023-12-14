"""
koopa module.
Updated 2023-12-14.
"""

from json import load
from os import scandir, walk
from os.path import abspath, basename, dirname, isdir, isfile, join
from platform import machine, system


def app_json_data() -> dict:
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
    Updated 2023-12-14.

    See also:
    - https://stackoverflow.com/a/10824086
    """
    try:
        for i, x in enumerate(items):
            while isinstance(x, seqtypes):
                items[i: i + 1] = x
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


def list_subdirs(path: str, recursive=False, basename_only=False) -> list:
    """
    List subdirectories in a directory.
    Updated 2023-12-14.

    See also:
    - https://stackoverflow.com/questions/141291/
    - https://stackoverflow.com/questions/800197/
    - https://www.techiedelight.com/list-all-subdirectories-in-directory-python/

    Examples:
    list_subdirs(path="/opt/koopa", recursive=False, basename_only=True)
    """
    if recursive:
        lst = []
        for path, dirs, files in walk(path):
            for subdir in dirs:
                lst.append(join(path, subdir))
    else:
        lst = [val.path for val in scandir(path) if val.is_dir()]
    if basename_only:
        lst = [basename(val) for val in lst]
        # Alternative approach using `map()`.
        # > lst = list(map(basename, lst))
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


def shared_apps(mode: str) -> list:
    """
    Return names of shared apps.
    Updated 2023-12-14.
    """
    if mode not in ["all_supported", "default_only"]:
        raise ValueError("Invalid mode.")
    sys_dict = {"opt_prefix": koopa_opt_prefix(), "os_id": os_id()}
    json_data = app_json_data()
    app_names = json_data.keys()
    out = []
    for val in app_names:
        if mode != "default_only":
            if isdir(join(sys_dict["opt_prefix"], val)):
                out.append(val)
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
        out.append(val)
    return out
