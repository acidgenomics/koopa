"""Install metadata functions."""

import os
import re
from datetime import UTC, datetime
from json import dumps

from koopa.io import import_app_json
from koopa.system import os_id

_SENSITIVE_KEY_RE = re.compile(
    r"(_KEY|_TOKEN|_SECRET|_PASSWORD|_CREDENTIAL|_AUTH|_PAT)$"
    r"|(_KEY_|_TOKEN_|_SECRET_|_PASSWORD_|_CREDENTIAL_|_AUTH_|_PAT_)"
    r"|(API_KEY|API_TOKEN|API_SECRET|API_PAT|ACCESS_TOKEN|REFRESH_TOKEN)"
    r"|(AUTH_SOCK|AUTH_BASE64)",
    re.IGNORECASE,
)


def _filter_environ() -> dict[str, str]:
    """Filter sensitive variables from environment before serialization."""
    return {k: v for k, v in sorted(os.environ.items()) if not _SENSITIVE_KEY_RE.search(k)}


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
        if isinstance(resolved_entry, dict):
            rev = int(resolved_entry.get("revision", 0))
            if rev > 0:
                dep_revisions[resolved_d] = rev
            ver = resolved_entry.get("version", "")
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
        "environ": _filter_environ(),
    }
    with open(output_file, "w") as fh:
        fh.write(dumps(info, indent=2, sort_keys=False))
        fh.write("\n")
