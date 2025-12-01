"""Application management functions."""

from datetime import datetime
from json import loads
from os.path import isdir, islink, join, realpath
from shutil import rmtree
from subprocess import run

from koopa.data import argsort, flatten, unique_pos
from koopa.fs import list_subdirs
from koopa.io import import_app_json
from koopa.os import arch2, koopa_app_prefix, koopa_opt_prefix, os_id


def app_deps(name: str) -> list:
    """Get application dependencies."""
    json_data = import_app_json()
    keys = json_data.keys()
    if name not in keys:
        raise NameError(f"Unsupported app: {name!r}.")
    lst = []
    deps = extract_app_deps(name=name, json_data=json_data)
    if not deps:
        return lst
    i = 0
    lst.append(deps)
    while i <= len(deps):
        lvl1 = []
        for lvl2 in lst[i]:
            if isinstance(lvl2, list):
                for lvl3 in lvl2:
                    lvl4 = extract_app_deps(name=lvl3, json_data=json_data)
                    if lvl4:
                        lvl1.append(lvl4)
            else:
                lvl3 = extract_app_deps(name=lvl2, json_data=json_data)
                if lvl3:
                    lvl1.append(lvl3)
        if not lvl1:
            break
        lst.append(lvl1)
        i = i + 1
    lst.reverse()
    lst = flatten(lst)
    lst = list(dict.fromkeys(lst))
    lst = filter_app_deps(names=lst, json_data=json_data)
    return lst


def app_revdeps(name: str, mode: str) -> list:
    """Get reverse application dependencies."""
    json_data = import_app_json()
    keys = list(json_data.keys())
    if name not in keys:
        raise NameError(f"Unsupported app: {name!r}.")
    all_deps = []
    for key in keys:
        key_deps = extract_app_deps(name=key, json_data=json_data, include_build_deps=False)
        all_deps.append(key_deps)
    lst = []
    i = 0
    while i < len(all_deps):
        if name in all_deps[i]:
            lst.append(keys[i])
        i += 1
    if not lst:
        return lst
    lst = filter_app_revdeps(names=lst, json_data=json_data, mode=mode)
    return lst


def extract_app_deps(name: str, json_data: dict, include_build_deps=True) -> list:
    """Extract unique build dependencies and dependencies in an ordered list.

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
            if sys_dict["os_id"] in build_deps:
                build_deps = build_deps[sys_dict["os_id"]]
            else:
                build_deps = build_deps["noarch"]
    if "dependencies" in json_data[name]:
        deps = json_data[name]["dependencies"]
        if isinstance(deps, dict):
            if sys_dict["os_id"] in deps:
                deps = deps[sys_dict["os_id"]]
            else:
                deps = deps["noarch"]
    all_deps = build_deps + deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


def filter_app_deps(names: list, json_data: dict) -> list:
    """Filter supported app dependencies."""
    sys_dict = {"os_id": os_id()}
    lst = []
    for val in names:
        json = json_data[val]
        keys = json.keys()
        if "supported" in keys:
            if sys_dict["os_id"] in json["supported"]:
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
    """Filter supported app reverse dependencies."""
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


def installed_apps() -> list:
    """List installed apps."""
    app_prefix = koopa_app_prefix()
    names = list_subdirs(path=app_prefix, recursive=False, sort=True, basename_only=True)
    return names


def prune_apps(dry_run=False) -> None:
    """Prune apps."""
    app_prefix = koopa_app_prefix()
    json_data = import_app_json()
    supported_names = json_data.keys()
    installed_names = installed_apps()
    opt_prefix = koopa_opt_prefix()
    for name in installed_names:
        prune = True
        if name not in supported_names:
            raise ValueError(f"{name!r} is not a supported app.")
        json = json_data[name]
        if "prune" in json:
            if not json["prune"]:
                prune = False
        if not prune:
            continue
        opt_path = join(opt_prefix, name)
        if not islink(opt_path):
            raise ValueError(f"{name!r} is not linked in {opt_prefix!r}.")
        linked_subdir = realpath(opt_path)
        subdirs = list_subdirs(
            path=join(app_prefix, name),
            recursive=False,
            sort=True,
            basename_only=False,
        )
        for subdir in subdirs:
            if subdir == linked_subdir:
                continue
            if dry_run:
                print(f"[dry-run] Pruning {subdir!r}.")
                continue
            print(f"Pruning {subdir!r}.")
            rmtree(subdir)


def prune_app_binaries(dry_run=False) -> None:
    """Prune app binaries.

    See Also
    --------
    - https://stackoverflow.com/questions/27274996/
    """
    dict = {
        "bucket": "private.koopa.acidgenomics.com",
        "profile": "acidgenomics",
        "subdir": "binaries",
    }
    bucket_uri = "s3://" + dict["bucket"] + "/"
    print(f"Pruning binaries in {bucket_uri!r}.")
    # Return AWS JSON using CLI.
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
            "--prefix",
            dict["subdir"] + "/",
        ],
        capture_output=True,
        check=True,
    )
    # Parse JSON return from AWS CLI.
    json = loads(json.stdout)
    json = json["Contents"]
    # Prepare our lists of values from JSON.
    apps = []
    dts = []
    keys = []
    for item in json:
        keys.append(item["Key"])
        # Convert app-specific key from "<OS>/<ARCH>/<APP>/<VERSION>.tar.gz" to
        # "<OS>/<ARCH>/<APP>/<VERSION>" for duplicate parsing.
        apps.append("/".join(item["Key"].split("/")[0:-1]))
        # Convert AWS `LastModified` value from ISO8601 to Python datetime.
        dts.append(datetime.fromisoformat(item["LastModified"]))
    # Sort lists by timestamp (newest to oldest).
    idx = argsort(dts, reverse=True)
    apps = [apps[i] for i in idx]
    dts = [dts[i] for i in idx]
    keys = [keys[i] for i in idx]
    # Get index positions of first unique app build.
    idx = unique_pos(apps)
    keys_ok = [keys[i] for i in idx]
    keys_ko = [x for x in keys if x not in set(keys_ok)]
    if not keys_ko:
        raise ValueError("No app binaries to prune.")
    keys_ko.sort()
    # Print the binaries to prune and return in dry-run mode.
    if dry_run:
        print(keys_ko)
        return None
    # Prune app binaries.
    for key in keys_ko:
        uri = bucket_uri + key
        run(
            args=["aws", "--profile", dict["profile"], "s3", "rm", uri],
            check=True,
        )
    return None


def shared_apps(mode: str) -> list:
    """Return names of shared apps."""
    if mode not in ["all", "default"]:
        raise ValueError("Invalid mode.")
    sys_dict = {"os_id": os_id(), "opt_prefix": koopa_opt_prefix()}
    json_data = import_app_json()
    names = json_data.keys()
    out = []
    for val in names:
        json = json_data[val]
        keys = json.keys()
        if "removed" in keys:
            if json["removed"]:
                continue
        if isdir(join(sys_dict["opt_prefix"], val)):
            out.append(val)
            continue
        if "supported" in json:
            if sys_dict["os_id"] in json["supported"].keys():
                if not json["supported"][sys_dict["os_id"]]:
                    continue
        if "default" in keys and mode != "all":
            if not json["default"]:
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
