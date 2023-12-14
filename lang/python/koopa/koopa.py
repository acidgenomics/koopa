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
    json_data = import_json(file)
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


def snake_case(string):
    """
    Snake case.
    Updated 2023-12-14.
    """
    string = sub(pattern="[^0-9a-zA-Z]+", repl="_", string=string)
    string = string.lower()
    return string
