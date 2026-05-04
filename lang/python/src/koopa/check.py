"""System check functions."""

from __future__ import annotations

import os
import shutil
import subprocess
from os.path import basename, isdir, isfile, islink, join, realpath

from koopa.app import extract_app_deps, installed_apps
from koopa.io import import_app_json
from koopa.os import koopa_opt_prefix
from koopa.prefix import (
    bash_completions_prefix,
    bootstrap_prefix,
    fish_completions_prefix,
    koopa_prefix,
    zsh_completions_prefix,
)


def _iter_installed_app_issues() -> list[tuple[str, str, bool]]:
    """Return ``(app_name, reason, actionable)`` for each installed app issue.

    *actionable* is True when the issue can be fixed by reinstalling the app
    (version mismatch, broken symlink).  Unsupported or removed apps are not
    actionable.
    """
    from koopa.prefix import bin_prefix, man1_prefix

    opt_prefix = koopa_opt_prefix()
    bin_dir = bin_prefix()
    man1_dir = man1_prefix()
    json_data = import_app_json()
    names = installed_apps()
    issues: list[tuple[str, str, bool]] = []
    from koopa.os import os_id

    current_os = os_id()
    for name in names:
        if name not in json_data:
            issues.append((name, f"{name} is an unsupported app", False))
            continue
        entry = json_data[name]
        supported = entry.get("supported", {})
        if current_os in supported and not supported[current_os]:
            issues.append((name, f"{name} is not supported on {current_os}", False))
            continue
        path = join(opt_prefix, name)
        if not islink(path):
            issues.append((name, f"{name} is not linked at {path}", True))
            continue
        path = realpath(path)
        if not isdir(path):
            issues.append(
                (name, f"{name} is not a directory at {path}", True),
            )
            continue
        assert isdir(path)
        linked_ver = basename(path)
        if json_data[name].get("removed"):
            issues.append((name, f"{name} is a removed app", False))
            continue
        current_ver = json_data[name]["version"]
        if len(current_ver) == 40:
            current_ver = current_ver[:7]
        if linked_ver != current_ver:
            issues.append(
                (name, f"{name} ({linked_ver} != {current_ver})", True),
            )
            continue
        expected_rev = entry.get("revision", 0)
        if expected_rev > 0:
            rev_file = join(path, ".install", "revision")
            installed_rev = 0
            if isfile(rev_file):
                try:
                    with open(rev_file) as f:
                        installed_rev = int(f.read().strip() or "0")
                except (ValueError, OSError):
                    pass
            if installed_rev != expected_rev:
                issues.append(
                    (name, f"{name} (revision {installed_rev} != {expected_rev})", True),
                )
                continue
        expected_bins = entry.get("bin", [])
        broken_bin = False
        for b in expected_bins:
            link = join(bin_dir, b)
            if islink(link) and not os.path.exists(link):
                issues.append(
                    (name, f"{name} (broken bin symlink: {b})", True),
                )
                broken_bin = True
                break
        if broken_bin:
            continue
        expected_man1 = entry.get("man1", [])
        for m in expected_man1:
            link = join(man1_dir, m)
            if islink(link) and not os.path.exists(link):
                issues.append(
                    (name, f"{name} (broken man1 symlink: {m})", True),
                )
                break
        # Check for missing shell completion symlinks (bash, fish, zsh).
        from koopa.install import (
            _find_bash_completion_files,
            _find_fish_completion_files,
            _find_zsh_completion_files,
        )

        for find_fn, central_dir, shell in (
            (_find_bash_completion_files, bash_completions_prefix(), "bash"),
            (_find_fish_completion_files, fish_completions_prefix(), "fish"),
            (_find_zsh_completion_files, zsh_completions_prefix(), "zsh"),
        ):
            for _source, completion_name in find_fn(path):
                link = join(central_dir, completion_name)
                if not islink(link) or not os.path.exists(link):
                    issues.append(
                        (
                            name,
                            f"{name} (missing {shell} completion: {completion_name})",
                            True,
                        ),
                    )
                    break
    return issues


def outdated_apps() -> list[str]:
    """Return names of installed apps that need updating."""
    return [name for name, _reason, actionable in _iter_installed_app_issues() if actionable]


def outdated_apps_with_reasons() -> list[tuple[str, str]]:
    """Return (name, reason) for installed apps that need updating."""
    return [
        (name, reason) for name, reason, actionable in _iter_installed_app_issues() if actionable
    ]


def unsupported_apps() -> list[str]:
    """Return names of installed apps no longer in app.json or marked removed."""
    return [name for name, _reason, actionable in _iter_installed_app_issues() if not actionable]


def check_installed_apps() -> bool:
    """Check system integrity."""
    issues = _iter_installed_app_issues()
    for _name, reason, _actionable in issues:
        print(reason)
    return not issues


def _iter_broken_app_installs() -> list[tuple[str, str]]:
    """Return ``(app_name, reason)`` for each broken app install."""
    from koopa.prefix import app_prefix as get_app_prefix

    app_dir = get_app_prefix()
    opt_prefix = koopa_opt_prefix()
    issues: list[tuple[str, str]] = []
    if not isdir(app_dir):
        return issues
    for name in sorted(os.listdir(app_dir)):
        app_path = join(app_dir, name)
        if not isdir(app_path):
            continue
        opt_link = join(opt_prefix, name)
        if islink(opt_link) and isdir(realpath(opt_link)):
            linked_path = realpath(opt_link)
            if not isfile(join(linked_path, ".install", "info.json")):
                issues.append(
                    (name, f"{name}: failed install (empty .install directory)"),
                )
            continue
        versions = [v for v in os.listdir(app_path) if isdir(join(app_path, v))]
        if not versions:
            issues.append((name, f"{name}: failed install (empty app directory)"))
            continue
        for ver in versions:
            ver_path = join(app_path, ver)
            if isdir(join(ver_path, ".install")):
                if not isfile(join(ver_path, ".install", "info.json")):
                    issues.append(
                        (name, f"{name}/{ver}: failed install (empty .install directory)"),
                    )
                else:
                    issues.append(
                        (name, f"{name}/{ver}: installed but not linked in opt"),
                    )
            else:
                issues.append(
                    (name, f"{name}/{ver}: failed install (no .install marker)"),
                )
    return issues


def broken_app_installs() -> list[str]:
    """Return names of apps with broken or incomplete installs."""
    return list(dict.fromkeys(name for name, _reason in _iter_broken_app_installs()))


def check_broken_app_installs() -> bool:
    """Check for broken app installs.

    Scans app prefix for directories that have no corresponding opt symlink,
    indicating a failed or incomplete install. Reports empty version
    directories that should be cleaned up.
    """
    issues = _iter_broken_app_installs()
    for _name, reason in issues:
        print(reason)
    return not issues


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
                cycles.append([*path[cycle_start:], dep])
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
    except OSError:
        return ""
    if result.returncode != 0:
        return ""
    return extract_version(result.stdout or result.stderr)


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
        assert path is not None
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
    seen: set[str] = set()
    for r_bin in (
        "/usr/local/bin/R",
        "/Library/Frameworks/R.framework/Resources/bin/R",
    ):
        if not os.path.isfile(r_bin) or not os.access(r_bin, os.X_OK):
            continue
        real = os.path.realpath(r_bin)
        if real in seen:
            continue
        seen.add(real)
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

            warn(f"System R is out of date at '{r_bin}': {installed} != {expected}.")
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
    seen: set[str] = set()
    for python_bin in (
        "/usr/local/bin/python3",
        "/Library/Frameworks/Python.framework/Versions/Current/bin/python3",
    ):
        if not os.path.isfile(python_bin) or not os.access(python_bin, os.X_OK):
            continue
        real = os.path.realpath(python_bin)
        if real in seen:
            continue
        seen.add(real)
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

            warn(f"System Python is out of date at '{python_bin}': {installed} != {expected}.")
            ok = False
    return ok


def _user_app_prefixes() -> dict[str, str]:
    """Return mapping of user-mode app names to their install prefixes."""
    from koopa.prefix import (
        doom_emacs_prefix,
        prelude_emacs_prefix,
        spacemacs_prefix,
        spacevim_prefix,
    )

    return {
        "doom-emacs": doom_emacs_prefix(),
        "prelude-emacs": prelude_emacs_prefix(),
        "spacemacs": spacemacs_prefix(),
        "spacevim": spacevim_prefix(),
    }


def _iter_outdated_user_apps() -> list[tuple[str, str]]:
    """Return ``(app_name, reason)`` for each outdated user-mode app."""
    from koopa.git import git_last_commit_local, is_git_repo

    json_data = import_app_json()
    prefixes = _user_app_prefixes()
    issues: list[tuple[str, str]] = []
    for name, prefix in prefixes.items():
        if not isdir(prefix):
            continue
        if not is_git_repo(prefix):
            continue
        if name not in json_data:
            continue
        expected = json_data[name].get("version", "")
        if not expected:
            continue
        try:
            installed = git_last_commit_local(prefix)
        except Exception:
            continue
        if installed != expected:
            short_installed = installed[:7] if len(installed) == 40 else installed
            short_expected = expected[:7] if len(expected) == 40 else expected
            issues.append(
                (name, f"{name} ({short_installed} != {short_expected})"),
            )
    return issues


def outdated_user_apps() -> list[str]:
    """Return names of user-mode apps that need updating."""
    return [name for name, _reason in _iter_outdated_user_apps()]


def check_user_apps() -> bool:
    """Check user-mode app versions."""
    issues = _iter_outdated_user_apps()
    for _name, reason in issues:
        print(reason)
    return not issues


def check_broken_symlinks() -> bool:
    """Check for broken symlinks in bin, opt, and man1 directories."""
    from koopa.file_ops import find_broken_symlinks
    from koopa.prefix import bin_prefix, man1_prefix, opt_prefix

    ok = True
    for prefix in (bin_prefix(), opt_prefix(), man1_prefix()):
        if not isdir(prefix):
            continue
        broken = find_broken_symlinks(prefix)
        for link in broken:
            ok = False
            print(f"broken symlink: {link}")
    return ok


def prune_broken_symlinks() -> None:
    """Remove broken symlinks from bin, opt, and man1 directories."""
    from koopa.file_ops import delete_broken_symlinks
    from koopa.prefix import bin_prefix, man1_prefix, opt_prefix

    for prefix in (bin_prefix(), opt_prefix(), man1_prefix()):
        if not isdir(prefix):
            continue
        delete_broken_symlinks(prefix)


def check_system() -> bool:
    """Run all system checks."""
    from koopa.alert import alert_note, alert_success, warn
    from koopa.system import is_macos

    ok = True
    check_build_system()
    if not check_bootstrap_version():
        ok = False
    if is_macos():
        if not check_macos_system_r():
            ok = False
        if not check_macos_system_python():
            ok = False
    if not check_installed_apps():
        ok = False
    if not check_broken_app_installs():
        ok = False
    if not check_user_apps():
        ok = False
    if not check_broken_symlinks():
        ok = False
    if not check_disk("/"):
        ok = False
    if not ok:
        warn("System checks completed with warnings.")
        alert_note("Run 'koopa update' to resolve these issues.")
        return False
    alert_success("System passed all checks.")
    return True
