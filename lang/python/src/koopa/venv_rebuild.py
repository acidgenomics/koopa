"""Determine whether a Python app can survive an interpreter rebuild."""

import json
import os
import re
from pathlib import Path

from koopa.io import app_version
from koopa.prefix import opt_prefix
from koopa.system import os_id


def can_preserve_python_venv(name: str, dep: str, registry: dict) -> bool:
    """Return whether a venv can safely retain a rebuilt Python dependency.

    Only same-version, same-revision interpreters reached through the stable
    opt link qualify. Native components remain conservative because their
    shared-library dependencies may have changed independently of Python.

    Parameters
    ----------
    name : str
        Installed dependent app.
    dep : str
        Resolved Python dependency name.
    registry : dict
        Current application registry.

    Returns
    -------
    bool
        True only when the installed venv is safe to preserve.
    """
    app = registry.get(name, {})
    python = registry.get(dep, {})
    if (
        not isinstance(app, dict)
        or app.get("installer") != "python-package"
        or not isinstance(python, dict)
        or not re.fullmatch(r"python3\.\d+", dep)
    ):
        return False
    opt = Path(opt_prefix())
    python_link = opt / dep
    app_link = opt / name
    if not python_link.is_symlink() or not python_link.is_dir() or not app_link.is_symlink():
        return False
    try:
        version = _matching_python_version(app_link, python_link, dep, python)
        if not version:
            return False
        venv = app_link / "libexec"
        return _matches_venv(venv, python_link, dep, version) and _is_pure_venv(venv, dep)
    except (OSError, ValueError, TypeError, KeyError):
        return False


def _matching_python_version(app: Path, python: Path, dep: str, entry: dict) -> str:
    info = json.loads((app / ".install" / "info.json").read_text())
    versions = info["dep_versions"]
    revisions = info["dep_revisions"]
    if not isinstance(versions, dict) or not isinstance(revisions, dict):
        return ""
    version = versions.get(dep)
    if not isinstance(version, str) or not version:
        return ""
    if version != python.resolve(strict=True).name or version != app_version(entry, os_id()):
        return ""
    revision_file = python / ".install" / "revision"
    installed_revision = int(revision_file.read_text().strip()) if revision_file.exists() else 0
    recorded_revision = revisions.get(dep, 0)
    if (
        not isinstance(recorded_revision, int)
        or installed_revision != recorded_revision
        or installed_revision != entry.get("revision", 0)
    ):
        return ""
    return version


def _matches_venv(venv: Path, python: Path, dep: str, version: str) -> bool:
    interpreter = venv / "bin" / dep
    if not interpreter.is_symlink() or not interpreter.is_file():
        return False
    target = os.readlink(interpreter)
    if not os.path.isabs(target) or os.path.normpath(target) != str(python / "bin" / dep):
        return False
    cfg = {}
    for line in (venv / "pyvenv.cfg").read_text().splitlines():
        key, sep, value = line.partition("=")
        if sep:
            cfg[key.strip()] = value.strip()
    return cfg.get("home") == str(python / "bin") and cfg.get("version") == version


def _is_pure_venv(venv: Path, dep: str) -> bool:
    site_packages = venv / "lib" / dep / "site-packages"
    if not site_packages.is_dir():
        return False
    for location in (site_packages, venv / "bin"):
        for root, dirs, files in os.walk(location, onerror=_raise_walk_error):
            if any((Path(root) / directory).is_symlink() for directory in dirs):
                return False
            for filename in files:
                if (
                    filename.endswith((".so", ".dylib", ".pyd", ".pth", ".egg-link"))
                    or ".so." in filename
                ):
                    return False
                path = Path(root) / filename
                if path.is_symlink():
                    if Path(root) == venv / "bin" and path.resolve(strict=True) == (
                        venv / "bin" / dep
                    ).resolve(strict=True):
                        continue
                    return False
                if path.stat().st_mode & 0o111:
                    with path.open("rb") as file:
                        magic = file.read(4)
                    if magic in (
                        b"\x7fELF",
                        b"\xfe\xed\xfa\xce",
                        b"\xce\xfa\xed\xfe",
                        b"\xfe\xed\xfa\xcf",
                        b"\xcf\xfa\xed\xfe",
                        b"\xca\xfe\xba\xbe",
                        b"\xbe\xba\xfe\xca",
                        b"\xca\xfe\xba\xbf",
                        b"\xbf\xba\xfe\xca",
                    ):
                        return False
    return True


def _raise_walk_error(error: OSError) -> None:
    raise error
