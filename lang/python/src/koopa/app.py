"""Application management functions."""

from datetime import datetime
from json import loads
from os.path import isdir, islink, join, realpath
from shutil import rmtree
from subprocess import run

from koopa.data import argsort, unique_pos
from koopa.fs import list_subdirs
from koopa.io import import_app_json
from koopa.os import arch2, koopa_app_prefix, koopa_opt_prefix, os_id


def app_deps(name: str) -> list:
    """Get application dependencies in topological order (deepest first)."""
    json_data = import_app_json()
    if name not in json_data:
        raise NameError(f"Unsupported app: {name!r}.")
    order: list[str] = []
    visited: set[str] = set()

    def _dfs(node: str) -> None:
        if node in visited:
            return
        visited.add(node)
        for dep in extract_app_deps(name=node, json_data=json_data):
            if dep in json_data:
                _dfs(dep)
        order.append(node)

    for dep in extract_app_deps(name=name, json_data=json_data):
        if dep in json_data:
            _dfs(dep)
    return filter_app_deps(names=order, json_data=json_data)


def app_revdeps(name: str, mode: str, include_build_deps: bool = True) -> list:
    """Get reverse application dependencies."""
    json_data = import_app_json()
    if name not in json_data:
        raise NameError(f"Unsupported app: {name!r}.")
    lst = [
        key
        for key in json_data
        if name
        in extract_app_deps(
            name=key,
            json_data=json_data,
            include_build_deps=include_build_deps,
        )
    ]
    if not lst:
        return lst
    return filter_app_revdeps(names=lst, json_data=json_data, mode=mode)


def _resolve_dep_dict(dep_dict: dict, sys_dict: dict) -> list:
    """Resolve a dependency dictionary to a list of dependency names.

    Supports three dispatch strategies, checked in order:

    1. **firewall** conditional - keys such as ``"firewall"``,
       ``"firewall_linux"``, ``"firewall_macos"`` combined with a
       ``"default"`` fallback.  When ``SSL_CERT_FILE`` is set externally the
       firewall-prefixed key matching the current platform is used;
       otherwise the ``"default"`` key is used.
    2. **os_id** dispatch - e.g. ``"macos-arm64"``, ``"linux-amd64"`` with a
       ``"noarch"`` fallback (existing behaviour).
    3. Plain list (not a dict) - returned as-is by the caller before this
       function is reached.
    """
    from koopa.install import can_build_binary
    from koopa.system import has_firewall, is_macos

    # Strategy 1: firewall / builder conditional.
    has_fw_keys = any(k.startswith("firewall") for k in dep_dict)
    if has_fw_keys:
        if has_firewall() or can_build_binary():
            platform_key = "firewall_macos" if is_macos() else "firewall_linux"
            if platform_key in dep_dict:
                return list(dep_dict[platform_key])
            if "firewall" in dep_dict:
                return list(dep_dict["firewall"])
        return list(dep_dict.get("default", []))

    # Strategy 2: os_id / noarch dispatch (existing behaviour).
    os_key = sys_dict["os_id"]
    if os_key in dep_dict:
        return list(dep_dict[os_key])
    return list(dep_dict.get("noarch", []))


def extract_app_deps(name: str, json_data: dict, include_build_deps: bool = True) -> list:
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
            build_deps = _resolve_dep_dict(build_deps, sys_dict)
    if "dependencies" in json_data[name]:
        deps = json_data[name]["dependencies"]
        if isinstance(deps, dict):
            deps = _resolve_dep_dict(deps, sys_dict)
    all_deps = build_deps + deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


def filter_app_deps(names: list, json_data: dict) -> list:
    """Filter supported app dependencies."""
    sys_dict = {"os_id": os_id()}
    lst = []
    for val in names:
        json = json_data[val]
        supported = json.get("supported", {})
        if sys_dict["os_id"] in supported and not supported[sys_dict["os_id"]]:
            continue
        if json.get("private"):
            continue
        if json.get("system"):
            continue
        if json.get("user"):
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
        if "alias_of" in keys:
            continue
        if "default" in keys and mode != "all" and not json["default"]:
            continue
        if "removed" in keys and json["removed"]:
            continue
        if (
            "supported" in keys
            and sys_dict["os_id"] in json["supported"]
            and not json["supported"][sys_dict["os_id"]]
        ):
            continue
        if "private" in keys and json["private"]:
            continue
        if "system" in keys and json["system"]:
            continue
        if "user" in keys and json["user"]:
            continue
        lst.append(val)
    return lst


def stale_revdeps(names: list) -> list:
    """Get installed apps whose runtime dependencies are being reinstalled.

    Given a list of app names being installed, returns any currently installed
    apps that have one or more of those names as a runtime dependency. Only
    considers 'dependencies', not 'build_dependencies'.
    """
    json_data = import_app_json()
    keys = list(json_data.keys())
    targets = set(names)
    installed = set(installed_apps())
    sys_dict = {"os_id": os_id()}
    lst = []
    for key in keys:
        if key not in installed:
            continue
        if key in targets:
            continue
        deps = []
        if "dependencies" in json_data[key]:
            deps = json_data[key]["dependencies"]
            if isinstance(deps, dict):
                deps = _resolve_dep_dict(deps, sys_dict)
        if targets.intersection(deps):
            lst.append(key)
    return lst


def installed_apps() -> list:
    """List installed apps."""
    app_prefix = koopa_app_prefix()
    names = list_subdirs(path=app_prefix, recursive=False, sort=True, basename_only=True)
    return names


def prune_apps(dry_run: bool = False) -> None:
    """Prune apps."""
    app_prefix = koopa_app_prefix()
    json_data = import_app_json()
    supported_names = json_data.keys()
    installed_names = installed_apps()
    opt_prefix = koopa_opt_prefix()
    for name in installed_names:
        if name not in supported_names:
            raise ValueError(f"{name!r} is not a supported app.")
        json = json_data[name]
        app_type = json.get("type", "library")
        if app_type != "cli":
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


def prune_app_binaries(dry_run: bool = False) -> None:
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
        if "alias_of" in keys:
            continue
        if "removed" in keys and json["removed"]:
            continue
        if isdir(join(sys_dict["opt_prefix"], val)):
            out.append(val)
            continue
        if (
            "supported" in json
            and sys_dict["os_id"] in json["supported"]
            and not json["supported"][sys_dict["os_id"]]
        ):
            continue
        if "default" in keys and mode != "all" and not json["default"]:
            continue
        if "private" in keys and json["private"]:
            continue
        if "system" in keys and json["system"]:
            continue
        if "user" in keys and json["user"]:
            continue
        out.append(val)
    return out
