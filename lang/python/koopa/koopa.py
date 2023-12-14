"""
koopa module.
Updated 2023-12-14.
"""

from json import load
from os import scandir, walk
from os.path import abspath, basename, dirname, expanduser, isdir, isfile, join
from platform import machine, system
from re import compile, sub
from subprocess import run


def app_deps(name: str) -> list:
    """
    Get application dependencies.
    Updated 2023-12-14.
    """
    json_data = import_app_json()
    keys = json_data.keys()
    if name not in keys:
        raise NameError("Unsupported app: '" + name + "'.")
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


# FIXME This is close but missing all supported apps...seems like mode isn't passing through?
# This needs to handle any installed apps that may be non-default.


def app_revdeps(name: str, mode: str) -> list:
    """
    Get reverse application dependencies.
    Updated 2023-10-13.
    """
    json_data = import_app_json()
    keys = list(json_data.keys())
    if name not in keys:
        raise NameError("Unsupported app: '" + name + "'.")
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
    # FIXME We need to not filter any installed non-default apps.
    lst = filter_app_revdeps(names=lst, json_data=json_data, mode=mode)
    return lst


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


def conda_bin_names(json_file: str) -> list:
    """
    Get the conda bin names from JSON file.
    Updated 2023-12-14.

    Examples:
    json_file="/opt/koopa/app/star/2.7.11a/libexec/conda-meta/star-2.7.11a-h0546b6b_0.json"
    conda_bin_names(json_file=json_file)
    """
    json_data = import_json(json_file)
    keys = json_data.keys()
    if "files" not in keys:
        raise ValueError("Invalid conda JSON file: '" + json_file + "'.")
    file_list = json_data["files"]
    bin_names = []
    pattern = compile(r"^bin/([^/]+)$")
    for file in file_list:
        match = pattern.match(file)
        if match:
            bin_name = match.group(1)
            bin_names.append(bin_name)
    return bin_names


def docker_build_all_tags(local: str, remote: str) -> bool:
    """
    Build all Docker tags.
    Updated 2023-12-14.

    Example:
    local = "~/monorepo/docker/acidgenomics/koopa"
    remote = "public.ecr.aws/acidgenomics/koopa"
    main(local=local, remote=remote)
    """
    local = abspath(expanduser(local))
    assert isdir(local)
    subdirs = list_subdirs(path=local, recursive=False, basename_only=True)
    for subdir in subdirs:
        local2 = join(local, subdir)
        assert isdir(local2)
        remote2 = remote + ":" + subdir
        docker_build_tag(local=local2, remote=remote2)
    return True


def docker_build_tag(local: str, remote: str) -> bool:
    """
    Build a Docker tag.
    Updated 2023-12-11.

    Examples:
    local = "~/monorepo/docker/acidgenomics/koopa/ubuntu"
    remote = "public.ecr.aws/acidgenomics/koopa:ubuntu"
    build_tag(local=local, remote=remote)
    """
    run(
        args=[
            "koopa",
            "app",
            "docker",
            "build",
            "--local",
            local,
            "--remote",
            remote,
        ],
        check=True,
    )
    return True


def extract_app_deps(
    name: str, json_data: dict, include_build_deps=True
) -> list:
    """
    Extract unique build dependencies and dependencies in an ordered list.
    Updated 2023-12-14.

    This makes list unique but keeps order intact, whereas usage of 'set()'
    can rearrange.
    """
    if name not in json_data:
        raise NameError("Unsupported app: '" + name + "'.")
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
    if mode not in ["all_supported", "default_only"]:
        raise ValueError("Invalid mode.")
    sys_dict = {"arch": arch2(), "opt_prefix": koopa_opt_prefix(), "os_id": os_id()}
    lst = []
    for val in names:
        if mode != "default_only":
            if isdir(join(sys_dict["opt_prefix"], val)):
                lst.append(val)
                continue
        json = json_data[val]
        keys = json.keys()
        if "default" in keys and mode != "all_supported":
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
                items[i : i + 1] = x
                x = items[i]
    except IndexError:
        pass
    return items


def kebab_case(string):
    """
    Kebab case.
    Updated 2023-12-14.
    """
    string = sub(pattern="[^0-9a-zA-Z]+", repl="-", string=string)
    string = string.lower()
    return string


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


def import_app_json() -> dict:
    """
    Import app.json data.
    Updated 2023-12-14.
    """
    file = join(koopa_prefix(), "etc/koopa/app.json")
    assert isfile(file)
    data = import_json(file)
    return data


def import_json(file: str) -> dict:
    """
    Import a JSON file.
    Updated 2023-12-14.
    """
    with open(file, encoding="utf-8") as con:
        data = load(con)
    return data


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


def print_app_deps(name: str) -> None:
    """
    Print app dependencies.
    Updated 2023-12-14.
    """
    lst = app_deps(name=name)
    print_list(lst)
    return None


def print_app_json(name: str, key: str) -> None:
    """
    Print values for an app.json key.
    Updated 2023-12-14.
    """
    json_data = import_app_json()
    keys = json_data.keys()
    if name not in keys:
        raise NameError("Unsupported app: '" + name + "'.")
    app_dict = json_data[name]
    if key not in app_dict.keys():
        raise ValueError("Invalid key: '" + key + "'.")
    value = app_dict[key]
    if isinstance(value, list):
        for i in value:
            print(i)
    else:
        print(value)
    return None


def print_app_revdeps(name: str, mode: str) -> None:
    """
    Print app dependencies.
    Updated 2023-12-14.
    """
    lst = app_revdeps(name=name, mode=mode)
    print_list(lst)
    return None


def print_conda_bin_names(json_file: str) -> None:
    """
    Print conda bin names.
    Updated 2023-12-14.
    """
    lst = conda_bin_names(json_file=json_file)
    print_list(lst)
    return None


def print_list(obj) -> None:
    """
    Loop across a list and print elements to console.
    Updated 2023-12-14.
    """
    if any(obj):
        for val in obj:
            print(val)
    return None


def print_shared_apps(mode: str) -> None:
    """
    Print shared apps.
    Updated 2023-12-14.
    """
    lst = shared_apps(mode=mode)
    print_list(lst)
    return None


def shared_apps(mode: str) -> list:
    """
    Return names of shared apps.
    Updated 2023-12-14.
    """
    if mode not in ["all_supported", "default_only"]:
        raise ValueError("Invalid mode.")
    sys_dict = {"os_id": os_id(), "opt_prefix": koopa_opt_prefix()}
    json_data = import_app_json()
    names = json_data.keys()
    out = []
    for val in names:
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


def snake_case(string):
    """
    Snake case.
    Updated 2023-12-14.
    """
    string = sub(pattern="[^0-9a-zA-Z]+", repl="_", string=string)
    string = string.lower()
    return string
