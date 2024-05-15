"""
Application management functions.
Updated 2025-05-05.
"""

from datetime import datetime
from json import loads
from os.path import isdir, join
from subprocess import run

from koopa.data import argsort, flatten, unique_pos
from koopa.io import import_app_json
from koopa.os import arch2, koopa_opt_prefix, os_id


def app_deps(name: str) -> list:
    """
    Get application dependencies.
    Updated 2024-05-05.
    """
    json_data = import_app_json()
    keys = json_data.keys()
    if name not in keys:
        raise NameError(f"Unsupported app: {name!r}.")
    lst = []
    deps = extract_app_deps(name=name, json_data=json_data)
    if len(deps) <= 0:
        return lst
    i = 0
    lst.append(deps)
    while i <= len(deps):
        lvl1 = []
        for lvl2 in lst[i]:
            if isinstance(lvl2, list):
                for lvl3 in lvl2:
                    lvl4 = extract_app_deps(name=lvl3, json_data=json_data)
                    if len(lvl4) > 0:
                        lvl1.append(lvl4)
            else:
                lvl3 = extract_app_deps(name=lvl2, json_data=json_data)
                if len(lvl3) > 0:
                    lvl1.append(lvl3)
        if len(lvl1) <= 0:
            break
        lst.append(lvl1)
        i = i + 1
    lst.reverse()
    lst = flatten(lst)
    lst = list(dict.fromkeys(lst))
    lst = filter_app_deps(names=lst, json_data=json_data)
    return lst


def app_revdeps(name: str, mode: str) -> list:
    """
    Get reverse application dependencies.
    Updated 2024-05-05.
    """
    json_data = import_app_json()
    keys = list(json_data.keys())
    if name not in keys:
        raise NameError(f"Unsupported app: {name!r}.")
    all_deps = []
    for key in keys:
        key_deps = extract_app_deps(
            name=key, json_data=json_data, include_build_deps=False
        )
        all_deps.append(key_deps)
    lst = []
    i = 0
    while i < len(all_deps):
        if name in all_deps[i]:
            lst.append(keys[i])
        i += 1
    if len(lst) <= 0:
        return lst
    lst = filter_app_revdeps(names=lst, json_data=json_data, mode=mode)
    return lst


def extract_app_deps(
    name: str, json_data: dict, include_build_deps=True
) -> list:
    """
    Extract unique build dependencies and dependencies in an ordered list.
    Updated 2024-05-05.

    This makes list unique but keeps order intact, whereas usage of 'set()'
    can rearrange.
    """
    if name not in json_data:
        raise NameError(f"Unsupported app: {name!r}.")
    sys_dict = {"os_id": os_id()}
    build_deps = []
    deps = []
    if include_build_deps and "build_dependencies" in json_data[name]:
        build_deps = json_data[name]["build_dependencies"]
        if isinstance(build_deps, dict):
            if sys_dict["os_id"] in build_deps.keys():
                build_deps = build_deps[sys_dict["os_id"]]
            else:
                build_deps = build_deps["noarch"]
    if "dependencies" in json_data[name]:
        deps = json_data[name]["dependencies"]
        if isinstance(deps, dict):
            if sys_dict["os_id"] in deps.keys():
                deps = deps[sys_dict["os_id"]]
            else:
                deps = deps["noarch"]
    all_deps = build_deps + deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


def filter_app_deps(names: list, json_data: dict) -> list:
    """
    Filter supported app dependencies.
    Updated 2023-12-14.
    """
    sys_dict = {"os_id": os_id()}
    lst = []
    for val in names:
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
        lst.append(val)
    return lst


def filter_app_revdeps(names: list, json_data: dict, mode: str) -> list:
    """
    Filter supported app reverse dependencies.
    Updated 2023-12-14.
    """
    if mode not in ["all", "default"]:
        raise ValueError("Invalid mode.")
    sys_dict = {
        "arch": arch2(),
        "opt_prefix": koopa_opt_prefix(),
        "os_id": os_id(),
    }
    lst = []
    for val in names:
        if isdir(join(sys_dict["opt_prefix"], val)):
            lst.append(val)
            continue
        json = json_data[val]
        keys = json.keys()
        if "default" in keys and mode != "all":
            if not json["default"]:
                continue
        if "removed" in keys:
            if json["removed"]:
                continue
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
        lst.append(val)
    return lst


def prune_app_binaries(dry_run=False) -> list:
    """
    Prune app binaries.
    Updated 2024-05-15.
    """
    dict = {
        "bucket": "private.koopa.acidgenomics.com",
        "profile": "acidgenomics",
        "subdir": "binaries",
    }
    url = "s3://" + dict["bucket"] + "/" + dict["subdir"] + "/"
    print(f"Pruning binaries in {url!r}.")
    json = run(
        args=[
            "aws",
            "--profile",
            dict["profile"],
            "s3api",
            "list-objects",
            "--bucket",
            dict["bucket"],
            "--output",
            "json",
        ],
        capture_output=True,
        check=True,
    )
    json = loads(json.stdout)
    json = json["Contents"]
    json_app = []
    json_dt = []
    json_key = []
    for item in json:
        json_app.append(item["Key"].split("/")[-2])
        json_dt.append(datetime.fromisoformat(item["LastModified"]))
        json_key.append(item["Key"])
    # First, sort by timestamp (newest to oldest).
    idx1 = argsort(json_dt, reverse=True)
    print(idx1)
    # FIXME Sort by app name and then timestamp.
    # FIXME Skip any apps that only have a single key.
    return json_key[0:4]


def shared_apps(mode: str) -> list:
    """
    Return names of shared apps.
    Updated 2023-12-14.
    """
    if mode not in ["all", "default"]:
        raise ValueError("Invalid mode.")
    sys_dict = {"os_id": os_id(), "opt_prefix": koopa_opt_prefix()}
    json_data = import_app_json()
    names = json_data.keys()
    out = []
    for val in names:
        if isdir(join(sys_dict["opt_prefix"], val)):
            out.append(val)
            continue
        json = json_data[val]
        keys = json.keys()
        if "supported" in json:
            if sys_dict["os_id"] in json["supported"].keys():
                if not json["supported"][sys_dict["os_id"]]:
                    continue
        if "default" in keys and mode != "all":
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
