"""System check functions."""

from __future__ import annotations

import os
import shutil
import subprocess
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


def _version_tuple(version: str) -> tuple[int, ...]:
    """Parse a version string into a tuple of integers for comparison."""
    parts = []
    for part in version.split("."):
        try:
            parts.append(int(part))
        except ValueError:
            break
    return tuple(parts)


def _get_version(path: str) -> str:
    """Get version string from a binary."""
    from koopa.version import extract_version

    try:
        result = subprocess.run(
            [path, "--version"],
            capture_output=True,
            text=True,
            check=False,
        )
        output = result.stdout or result.stderr
    except OSError:
        return ""
    return extract_version(output)


def check_build_system() -> bool:
    """Check that the current environment supports building from source."""
    from koopa.system import is_linux, is_macos

    ok = True
    if is_macos():
        try:
            result = subprocess.run(
                ["xcrun", "--show-sdk-path"],
                capture_output=True,
                text=True,
                check=False,
            )
            sdk_prefix = result.stdout.strip()
        except FileNotFoundError:
            sdk_prefix = ""
        if not sdk_prefix or not isdir(sdk_prefix):
            from koopa.alert import stop

            stop("Xcode CLT not installed. Run 'xcode-select --install' to resolve.")
    required = {
        "cc": "cc",
        "git": "git",
        "ld": "ld",
        "make": "make",
        "perl": "perl",
        "python": "python3",
    }
    min_versions: dict[str, str] = {
        "git": "1.8",
        "make": "3.8",
        "perl": "5.16",
        "python": "3.6",
    }
    if is_macos():
        min_versions["cc"] = "14.0"
    elif is_linux():
        min_versions["cc"] = "7.0"
    for key, cmd in required.items():
        path = shutil.which(cmd)
        if path is None:
            from koopa.alert import stop

            stop(f"'{cmd}' is not installed.")
        if key == "ld":
            continue
        version = _get_version(path)
        if not version:
            continue
        min_ver = min_versions.get(key)
        if min_ver is None:
            continue
        if _version_tuple(version) < _version_tuple(min_ver):
            from koopa.alert import stop

            stop(f"Unsupported {key}: {path} ({version} < {min_ver}).")
    return ok


def check_disk(path: str = "/") -> bool:
    """Check disk usage at a path."""
    from koopa.disk import disk_pct_used

    pct = disk_pct_used(path)
    if pct > 90:
        from koopa.alert import warn

        warn(f"Disk usage at '{path}' is {pct:.0f}%.")
        return False
    return True


def check_macos_system_r() -> bool:
    """Check if system R is current on macOS."""
    from koopa.version import extract_version

    json_data = import_app_json()
    expected = json_data.get("r", {}).get("version", "")
    if not expected:
        return True
    ok = True
    for r_bin in (
        "/usr/local/bin/R",
        "/Library/Frameworks/R.framework/Resources/bin/R",
    ):
        if not os.path.isfile(r_bin) or not os.access(r_bin, os.X_OK):
            continue
        try:
            result = subprocess.run(
                [r_bin, "--version"],
                capture_output=True,
                text=True,
                check=False,
            )
            installed = extract_version(result.stdout or result.stderr)
        except OSError:
            continue
        if installed and installed != expected:
            from koopa.alert import warn

            warn(
                f"System R is out of date at '{r_bin}': "
                f"{installed} != {expected}."
            )
            ok = False
    return ok


def check_macos_system_python() -> bool:
    """Check if system Python is current on macOS."""
    from koopa.version import extract_version, major_minor_version

    json_data = import_app_json()
    py_keys = sorted(
        (k for k in json_data if k.startswith("python3.")),
        reverse=True,
    )
    if not py_keys:
        return True
    latest_key = py_keys[0]
    expected = json_data[latest_key].get("version", "")
    if not expected:
        return True
    ok = True
    for python_bin in (
        "/usr/local/bin/python3",
        "/Library/Frameworks/Python.framework/Versions/Current/bin/python3",
    ):
        if not os.path.isfile(python_bin) or not os.access(python_bin, os.X_OK):
            continue
        try:
            result = subprocess.run(
                [python_bin, "--version"],
                capture_output=True,
                text=True,
                check=False,
            )
            installed = extract_version(result.stdout or result.stderr)
        except OSError:
            continue
        if not installed:
            continue
        inst_mm = major_minor_version(installed)
        exp_mm = major_minor_version(expected)
        if inst_mm != exp_mm:
            continue
        if installed != expected:
            from koopa.alert import warn

            warn(
                f"System Python is out of date at '{python_bin}': "
                f"{installed} != {expected}."
            )
            ok = False
    return ok


def check_system() -> bool:
    """Run all system checks."""
    from koopa.alert import alert_success, warn
    from koopa.system import is_macos

    ok = True
    check_build_system()
    if not check_bootstrap_version():
        warn("Run 'koopa install user bootstrap' to update.")
        ok = False
    if is_macos():
        if not check_macos_system_r():
            ok = False
        if not check_macos_system_python():
            ok = False
    if not check_installed_apps():
        ok = False
    if not check_disk("/"):
        ok = False
    if not ok:
        warn("System checks completed with warnings.")
        return False
    alert_success("System passed all checks.")
    return True
