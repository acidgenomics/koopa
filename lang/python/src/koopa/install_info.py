"""Install metadata functions."""

import os
from datetime import UTC, datetime
from json import dumps

from koopa.io import import_app_json
from koopa.prefix import opt_prefix
from koopa.system import os_id

# Build-diagnostic variables only. This is an allowlist, not a blocklist:
# info.json is packaged into pushed binary tarballs, so anything not named
# here never reaches disk. Do not add credential-shaped names (tokens, keys,
# DSNs) even if they look build-relevant.
_ENVIRON_ALLOWLIST = (
    "CC",
    "CXX",
    "CFLAGS",
    "CXXFLAGS",
    "CPPFLAGS",
    "LDFLAGS",
    "LD_LIBRARY_PATH",
    "DYLD_LIBRARY_PATH",
    "PATH",
    "PYTHONPATH",
    "GOPATH",
    "CONDA_PREFIX",
    "CONDA_EXE",
    "MACOSX_DEPLOYMENT_TARGET",
    "TMPDIR",
    "TERM",
    "KOOPA_PREFIX",
    "KOOPA_BUILDER",
    "KOOPA_IS_DOCKER",
    "KOOPA_VERBOSE",
    "KOOPA_INSTALL_JOBS",
    "KOOPA_INSTALL_APP_TIMEOUT",
    "KOOPA_INSTALL_APP_WARN",
)


def _capture_build_environ() -> dict[str, str]:
    """Capture a fixed allowlist of build-diagnostic variables for info.json."""
    return {k: os.environ[k] for k in _ENVIRON_ALLOWLIST if k in os.environ}


def _installed_dep_state(dep: str, fallback_entry: dict) -> tuple[str, int]:
    """Return (version, revision) for *dep* as actually installed under opt/.

    Falls back to *fallback_entry* (the app.json entry) when the dep isn't
    linked in opt/ yet, so recording never fails outright.
    """
    opt_link = os.path.join(opt_prefix(), dep)
    if os.path.islink(opt_link):
        target = os.path.realpath(opt_link)
        if os.path.isdir(target):
            version = os.path.basename(target)
            revision = 0
            rev_file = os.path.join(target, ".install", "revision")
            if os.path.isfile(rev_file):
                try:
                    with open(rev_file) as f:
                        revision = int(f.read().strip() or "0")
                except (ValueError, OSError):
                    revision = 0
            return version, revision
    return fallback_entry.get("version", ""), int(fallback_entry.get("revision", 0))


def write_install_info(output_file: str, name: str, version: str) -> None:
    """Write install metadata JSON file."""
    json_data = import_app_json()
    sys_dict = {"os_id": os_id()}
    build_deps = []
    deps = []
    soft_deps = []
    if name in json_data:
        entry = json_data[name]
        if "build_dependencies" in entry:
            bd = entry["build_dependencies"]
            if isinstance(bd, dict):
                from koopa.app import _resolve_dep_dict

                bd = _resolve_dep_dict(bd, sys_dict)
            build_deps = list(bd)
        if "dependencies" in entry:
            d = entry["dependencies"]
            if isinstance(d, dict):
                from koopa.app import _resolve_dep_dict

                d = _resolve_dep_dict(d, sys_dict)
            deps = list(d)
        if "soft_dependencies" in entry:
            sd = entry["soft_dependencies"]
            if isinstance(sd, dict):
                from koopa.app import _resolve_dep_dict

                sd = _resolve_dep_dict(sd, sys_dict)
            soft_deps = list(sd)
    dep_revisions: dict[str, int] = {}
    dep_versions: dict[str, str] = {}
    for d in deps:
        resolved_d = d
        d_entry = json_data.get(d, {})
        if isinstance(d_entry, dict) and d_entry.get("alias_of"):
            resolved_d = d_entry["alias_of"]
        resolved_entry = json_data.get(resolved_d, {})
        ver, rev = _installed_dep_state(
            resolved_d,
            resolved_entry if isinstance(resolved_entry, dict) else {},
        )
        if rev > 0:
            dep_revisions[resolved_d] = rev
        if ver:
            dep_versions[resolved_d] = ver
    info = {
        "name": name,
        "version": version,
        "date": datetime.now(tz=UTC).strftime("%Y-%m-%d %H:%M:%S"),
        "os_id": sys_dict["os_id"],
        "build_dependencies": build_deps,
        "dependencies": deps,
        "soft_dependencies": soft_deps,
        "dep_revisions": dep_revisions,
        "dep_versions": dep_versions,
        "environ": _capture_build_environ(),
    }
    with open(output_file, "w") as fh:
        fh.write(dumps(info, indent=2, sort_keys=False))
        fh.write("\n")
