"""System check functions."""

from os.path import basename, isdir, isfile, islink, join, realpath

from koopa.app import extract_app_deps, installed_apps
from koopa.io import import_app_json
from koopa.os import koopa_opt_prefix
from koopa.prefix import bootstrap_prefix, koopa_prefix


def check_installed_apps() -> bool:
    """Check system integrity."""
    ok = True
    opt_prefix = koopa_opt_prefix()
    json_data = import_app_json()
    names = installed_apps()
    for name in names:
        if name not in json_data:
            ok = False
            print(f"{name} is an unsupported app")
            continue
        path = join(opt_prefix, name)
        if not islink(path):
            ok = False
            print(f"{name} is not linked at {path}")
            continue
        path = realpath(path)
        if not isdir(path):
            ok = False
            print(f"{name} is not a directory at {path}")
            continue
        assert isdir(path)
        linked_ver = basename(path)
        if "removed" in json_data[name] and json_data[name]["removed"]:
            ok = False
            print(f"{name} is a removed app")
            continue
        current_ver = json_data[name]["version"]
        # Sanitize commit hashes.
        if len(current_ver) == 40:
            current_ver = current_ver[:7]
        if linked_ver != current_ver:
            ok = False
            print(f"{name} ({linked_ver} != {current_ver})")
            continue
    return ok


def check_circular_deps() -> list:
    """Check for circular dependencies in app.json.

    Returns a list of cycles, where each cycle is a list of package names
    forming the loop (e.g. ["curl", "zstd", "cmake", "curl"]).
    """
    json_data = import_app_json()
    names = list(json_data.keys())
    graph = {}
    for name in names:
        try:
            deps = extract_app_deps(name=name, json_data=json_data)
        except NameError:
            deps = []
        graph[name] = deps
    cycles = []
    white = set(names)
    gray = set()
    black = set()

    def _dfs(node: str, path: list) -> None:
        white.discard(node)
        gray.add(node)
        path.append(node)
        for dep in graph.get(node, []):
            if dep in gray:
                cycle_start = path.index(dep)
                cycles.append(path[cycle_start:] + [dep])
            elif dep in white:
                _dfs(dep, path)
        path.pop()
        gray.discard(node)
        black.add(node)

    for name in names:
        if name in white:
            _dfs(name, [])
    return cycles


def check_bootstrap_version() -> bool:
    """Check if bootstrap installation is current.

    Compares the installed bootstrap VERSION file against the expected
    version defined in 'etc/koopa/bootstrap-version.txt'.

    Returns
    -------
    bool
        True if versions match or bootstrap is not installed, False otherwise.
    """
    bp = bootstrap_prefix()
    kp = koopa_prefix()
    expected_version_file = join(kp, "etc", "koopa", "bootstrap-version.txt")
    installed_version_file = join(bp, "VERSION")
    if not isfile(expected_version_file):
        return True
    if not isdir(bp):
        return True
    if not isfile(installed_version_file):
        print(f"Bootstrap is installed but missing VERSION file at {installed_version_file}")
        return False
    with open(expected_version_file) as fh:
        expected_version = fh.read().strip()
    with open(installed_version_file) as fh:
        installed_version = fh.read().strip()
    if installed_version != expected_version:
        print(f"Bootstrap is out of date ({installed_version} != {expected_version})")
        return False
    return True
