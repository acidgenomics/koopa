"""Application management functions."""

import sys
import threading
import time
from collections.abc import Callable
from datetime import datetime
from json import loads
from os import chmod, getpid, rename
from os.path import basename, isdir, isfile, islink, join, realpath
from shutil import rmtree
from subprocess import run

from koopa.data import argsort, unique_pos
from koopa.fs import list_subdirs
from koopa.io import import_app_json
from koopa.prefix import app_prefix as koopa_app_prefix
from koopa.prefix import opt_prefix as koopa_opt_prefix
from koopa.system import arch2, os_id

_PRUNE_TRASH_PREFIX = ".koopa-prune-trash."

# Installer types that are purely download/extract — safe to run in parallel.
_IO_BOUND_INSTALLERS: frozenset[str] = frozenset(
    {
        "conda-package",
        "node-package",
        "python-package",
        "python-plugin",
        "ruby-package",
    }
)

# Installer types that compile from source and saturate all CPU cores.
_CPU_BOUND_INSTALLERS: frozenset[str] = frozenset(
    {
        "gnu-app",
        "haskell-package",
        "libtool",
        "openssl",
        "perl-package",
        "python",
        "r",
        "rust-package",
    }
)

# Ambiguous-bucket apps (no "installer" field, no "src_url") whose dedicated
# installer module only downloads a pre-built artifact — no compilation.
_DOWNLOAD_ONLY_APPS: frozenset[str] = frozenset(
    {
        "1password-cli",
        "anaconda",
        "apache-spark",
        "aspera-connect",
        "aws-mountpoint-s3",
        "bfg",
        "ca-certificates",
        "clickhouse",
        "conda",
        "databricks-cli",
        "dotfiles",
        "ensembl-perl-api",
        "freetype",
        "go",
        "gseapy",
        "haskell-ghcup",
        "illumina-ica-cli",
        "jfrog-cli",
        "julia",
        "ldc",
        "libidn",
        "ont-dorado",
        "oracle-instant-client",
        "powershell",
        "quarto",
        "r-gfortran",
        "r-xcode-openmp",
        "rstudio-server",
        "rust",
        "shiny-server",
        "surrealdb",
        "temurin",
        "uv",
    }
)


def is_cpu_bound_app(name: str, json_data: dict) -> bool:
    """Return True when installing this app will saturate CPU cores.

    CPU-bound apps compile from source (make -j, cargo, cmake --parallel,
    go build, etc.) and must not run concurrently with other CPU-bound builds.
    IO-bound apps only download and extract pre-built artifacts.

    Parameters
    ----------
    name : str
        Application name.
    json_data : dict
        Parsed app.json registry mapping app names to entries.

    Returns
    -------
    bool
        True if installing this app will saturate CPU cores.
    """
    entry = json_data.get(name)
    if not isinstance(entry, dict):
        return False
    installer = entry.get("installer", "")
    if installer in _IO_BOUND_INSTALLERS:
        return False
    if installer in _CPU_BOUND_INSTALLERS:
        return True
    if entry.get("src_url"):
        return True
    # Ambiguous bucket: no installer field, no src_url. Conservative default is
    # CPU-bound; the allowlist names apps we've verified are download-only.
    return name not in _DOWNLOAD_ONLY_APPS


def resolve_alias(name: str) -> str:
    """Resolve app alias to its target name (e.g. 'python' -> 'python3.14').

    Parameters
    ----------
    name : str
        Application name, possibly an alias.

    Returns
    -------
    str
        The target app name if name is an alias, otherwise name unchanged.
    """
    data = import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        alias = entry.get("alias_of", "")
        if alias:
            return alias
    return name


def app_json_bin(name: str) -> list[str]:
    """Get bin names for an app from app.json.

    Parameters
    ----------
    name : str
        Application name.

    Returns
    -------
    list[str]
        Binary names registered for the app, or an empty list if none.
    """
    data = import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        bins = entry.get("bin", [])
        if isinstance(bins, str):
            return [bins]
        if isinstance(bins, list):
            return bins
    return []


def app_json_man1(name: str) -> list[str]:
    """Get man1 page names for an app from app.json.

    Parameters
    ----------
    name : str
        Application name.

    Returns
    -------
    list[str]
        Man1 page names registered for the app, or an empty list if none.
    """
    data = import_app_json()
    entry = data.get(name, {})
    if isinstance(entry, dict):
        man1 = entry.get("man1", [])
        if isinstance(man1, str):
            return [man1]
        if isinstance(man1, list):
            return man1
    return []


def installer_artifact_key(name: str, version: str) -> str | None:
    """Get the S3 key for a private app's staged installer artifact.

    Reads the ``installer_artifact`` field (an S3 key template containing a
    ``{version}`` placeholder) from app.json and expands it. Returns ``None``
    when the app has no such field, which is the case for every app that isn't
    gated on a manually-staged vendor tarball (e.g. cellranger, bcl-convert).

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version to substitute into the S3 key template.

    Returns
    -------
    str | None
        Expanded S3 key for the staged installer artifact, or None if the
        app has no ``installer_artifact`` field.
    """
    data = import_app_json()
    entry = data.get(name, {})
    if not isinstance(entry, dict):
        return None
    template = entry.get("installer_artifact", "")
    if not template:
        return None
    return template.format(version=version)


def app_deps(name: str) -> list:
    """Get application dependencies in topological order (deepest first).

    Parameters
    ----------
    name : str
        Application name.

    Returns
    -------
    list
        Dependency names in topological order, deepest dependency first.
    """
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
    """Get reverse application dependencies.

    Parameters
    ----------
    name : str
        Application name to find reverse dependencies for.
    mode : str
        Filter mode, either ``"all"`` or ``"default"``.
    include_build_deps : bool, optional
        Whether to include build-only dependencies when resolving each
        candidate's dependency set.

    Returns
    -------
    list
        Names of apps that depend on name, filtered per mode.
    """
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

    Parameters
    ----------
    dep_dict : dict
        Dependency dictionary keyed by dispatch strategy (firewall or
        os_id) to resolve.
    sys_dict : dict
        System context dict containing at least the ``"os_id"`` key.

    Returns
    -------
    list
        Dependency names resolved for the current platform and firewall
        state.
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


def extract_app_deps(
    name: str,
    json_data: dict,
    include_build_deps: bool = True,
    include_soft_deps: bool = True,
) -> list:
    """Extract unique build dependencies and dependencies in an ordered list.

    This makes list unique but keeps order intact, whereas usage of 'set()'
    can rearrange.

    Parameters
    ----------
    name : str
        Application name to extract dependencies for.
    json_data : dict
        Parsed app.json registry mapping app names to entries.
    include_build_deps : bool, optional
        Whether to include the app's ``build_dependencies`` entries.
    include_soft_deps : bool, optional
        Whether to include the app's ``soft_dependencies`` entries.

    Returns
    -------
    list
        Unique dependency names in build, then runtime, then
        soft-dependency order.
    """
    if name not in json_data:
        raise NameError(f"Unsupported app: {name!r}.")
    sys_dict = {"os_id": os_id()}
    build_deps = []
    deps = []
    soft_deps = []
    if include_build_deps and "build_dependencies" in json_data[name]:
        build_deps = json_data[name]["build_dependencies"]
        if isinstance(build_deps, dict):
            build_deps = _resolve_dep_dict(build_deps, sys_dict)
    if "dependencies" in json_data[name]:
        deps = json_data[name]["dependencies"]
        if isinstance(deps, dict):
            deps = _resolve_dep_dict(deps, sys_dict)
    if include_soft_deps and "soft_dependencies" in json_data[name]:
        soft_deps = json_data[name]["soft_dependencies"]
        if isinstance(soft_deps, dict):
            soft_deps = _resolve_dep_dict(soft_deps, sys_dict)
    all_deps = build_deps + deps + soft_deps
    all_deps = list(dict.fromkeys(all_deps))
    return all_deps


def filter_app_deps(names: list, json_data: dict) -> list:
    """Filter supported app dependencies.

    Parameters
    ----------
    names : list
        Candidate dependency names to filter.
    json_data : dict
        Parsed app.json registry mapping app names to entries.

    Returns
    -------
    list
        Names from names that are supported on the current platform and
        are not private, system, or user apps.
    """
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
    """Filter supported app reverse dependencies.

    Parameters
    ----------
    names : list
        Candidate reverse dependency names to filter.
    json_data : dict
        Parsed app.json registry mapping app names to entries.
    mode : str
        Filter mode, either ``"all"`` or ``"default"``.

    Returns
    -------
    list
        Names from names that are installed, or that pass the supported,
        default, and visibility checks.
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


def recorded_app_deps(name: str) -> list | None:
    """Get the runtime dependency list recorded when *name* was installed.

    Reads ``opt/<name>/.install/info.json``'s ``"dependencies"`` key -- the
    dep set actually resolved at install time -- rather than re-resolving
    app.json's dependency dict against the *current* environment. A dict-typed
    'dependencies' entry (e.g. a ``firewall_linux``/``firewall_macos``/
    ``default`` split) resolves differently depending on ``KOOPA_BUILDER`` and
    firewall state, so re-resolving it now for an app installed under a
    different environment produces a phantom dependency list that was never
    actually linked, and callers comparing against it flag the app as stale
    for no real reason.

    Returns ``None`` (not an empty list) when nothing was recorded -- missing
    opt/ symlink, missing or unreadable info.json, or a pre-existing install
    from before this field was recorded -- so callers know to fall back to
    live re-resolution. A recorded empty list is authoritative and returned
    as-is.

    Parameters
    ----------
    name : str
        Application name whose recorded install-time dependency list to
        read.

    Returns
    -------
    list | None
        The recorded runtime dependency list, or None if nothing was
        recorded.
    """
    opt_link = join(koopa_opt_prefix(), name)
    if not islink(opt_link):
        return None
    target = realpath(opt_link)
    info_file = join(target, ".install", "info.json")
    if not isfile(info_file):
        return None
    try:
        with open(info_file) as f:
            info = loads(f.read())
    except (ValueError, OSError):
        return None
    deps = info.get("dependencies")
    if not isinstance(deps, list):
        return None
    return deps


def stale_revdeps_with_triggers(names: list[str]) -> dict[str, list[str]]:
    """Get installed reverse dependencies and the apps that trigger each rebuild.

    Given a list of app names being installed, returns any currently installed
    apps that have one or more of those names as a runtime dependency, mapped
    to the triggering dependency names. Only considers 'dependencies', not
    'build_dependencies'. Prefers each candidate's recorded install-time dep
    list (see `recorded_app_deps`) over app.json's current dict, falling back
    only when nothing was recorded.

    Parameters
    ----------
    names : list[str]
        Application names being installed or reinstalled.

    Returns
    -------
    dict[str, list[str]]
        Mapping of each installed app whose recorded dependencies include
        one of names to the list of triggering names.
    """
    json_data = import_app_json()
    keys = list(json_data.keys())
    targets = set(names)
    if not targets:
        return {}
    installed = set(installed_apps())
    sys_dict = {"os_id": os_id()}
    revdeps: dict[str, list[str]] = {}
    for key in keys:
        if key not in installed:
            continue
        if key in targets:
            continue
        deps = recorded_app_deps(key)
        if deps is None:
            deps = []
            if "dependencies" in json_data[key]:
                deps = json_data[key]["dependencies"]
                if isinstance(deps, dict):
                    deps = _resolve_dep_dict(deps, sys_dict)
        triggering: list[str] = []
        for d in deps:
            resolved_d = d
            d_entry = json_data.get(d, {})
            if isinstance(d_entry, dict) and d_entry.get("alias_of"):
                resolved_d = d_entry["alias_of"]
            if d in targets or resolved_d in targets:
                trigger = resolved_d if resolved_d in targets else d
                if trigger not in triggering:
                    triggering.append(trigger)
        if triggering:
            revdeps[key] = triggering
    return revdeps


def stale_revdeps(names: list[str]) -> list[str]:
    """Get installed apps whose runtime dependencies are being reinstalled.

    Parameters
    ----------
    names : list[str]
        Application names being installed or reinstalled.

    Returns
    -------
    list[str]
        Names of installed apps whose recorded runtime dependencies
        include one of names.
    """
    return list(stale_revdeps_with_triggers(names))


def installed_apps() -> list:
    """List installed apps.

    Returns
    -------
    list
        Names of apps currently installed under the koopa app prefix.
    """
    app_prefix = koopa_app_prefix()
    names = list_subdirs(path=app_prefix, recursive=False, sort=True, basename_only=True)
    return names


def _prune_spinner(stop: threading.Event, start: float) -> None:
    from koopa.progress import _SPINNER_FRAMES, _fmt_duration

    if not sys.stderr.isatty():
        return
    idx = 0
    while not stop.wait(0.2):
        frame = _SPINNER_FRAMES[idx % len(_SPINNER_FRAMES)]
        elapsed = _fmt_duration(time.monotonic() - start)
        print(f"\r\033[K   {frame} [{elapsed}]", end="", flush=True, file=sys.stderr)
        idx += 1
    print("\r\033[K", end="", flush=True, file=sys.stderr)


def _prune_rmtree_onexc(
    func: Callable[..., None],
    path: str,
    excinfo: BaseException,
) -> None:
    """Retry rmtree callbacks after fixing restrictive permissions.

    Parameters
    ----------
    func : Callable[..., None]
        Function that raised during rmtree's traversal. Unused, but kept
        to match shutil's onexc callback signature.
    path : str
        Path that failed to be removed.
    excinfo : BaseException
        Exception raised by the failed operation.
    """
    del func  # not reliably callable for all shutil internals (e.g. os.open).
    if isinstance(excinfo, PermissionError):
        chmod(path, 0o700)
        rmtree(path, ignore_errors=True)
        return
    raise excinfo


def prune_apps(dry_run: bool = False, verbose: bool = False) -> None:
    """Prune apps.

    Parameters
    ----------
    dry_run : bool, optional
        Print what would be pruned without deleting anything.
    verbose : bool, optional
        Print each subdirectory as it's pruned.
    """
    app_prefix = koopa_app_prefix()
    json_data = import_app_json()
    supported_names = json_data.keys()
    installed_names = installed_apps()
    opt_prefix = koopa_opt_prefix()
    pruned: list[str] = []
    to_delete: list[str] = []
    pid = getpid()
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
            # Sweep leftover trash from interrupted prior runs.
            if basename(subdir).startswith(_PRUNE_TRASH_PREFIX):
                to_delete.append(subdir)
                continue
            if subdir == linked_subdir:
                continue
            if dry_run:
                print(f"[dry-run] Pruning {subdir!r}.")
                continue
            if verbose:
                print(f"Pruning {subdir!r}.")
            # Rename into a hidden sibling first: atomic and O(1) on NFS,
            # removes the old version from the live namespace immediately.
            trash = join(app_prefix, name, f"{_PRUNE_TRASH_PREFIX}{basename(subdir)}.{pid}")
            try:
                rename(subdir, trash)
                to_delete.append(trash)
            except OSError:
                to_delete.append(subdir)
            pruned.append(subdir)
    if not dry_run and to_delete:
        from koopa.alert import alert

        alert("Pruning old app versions.")
        stop = threading.Event()
        spinner = threading.Thread(
            target=_prune_spinner, args=(stop, time.monotonic()), daemon=True
        )
        spinner.start()
        try:
            for path in to_delete:
                try:
                    rmtree(path, onexc=_prune_rmtree_onexc)
                except OSError:
                    continue
        finally:
            stop.set()
            spinner.join()
    if not dry_run and pruned:
        from koopa.alert import alert_success

        n = len(pruned)
        alert_success(f"Pruned {n} app version{'s' if n != 1 else ''}.")


def prune_app_binaries(dry_run: bool = False) -> None:
    """Prune app binaries.

    Parameters
    ----------
    dry_run : bool, optional
        Print the binary keys that would be pruned without deleting
        anything.

    Notes
    -----
    https://stackoverflow.com/questions/27274996/
    """
    from koopa.aws import koopa_s3_bucket

    dict = {
        "bucket": koopa_s3_bucket("artifacts"),
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
    """Return names of shared apps.

    Parameters
    ----------
    mode : str
        Filter mode, either ``"all"`` or ``"default"``.

    Returns
    -------
    list
        Names of shared apps, filtered per mode.
    """
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
