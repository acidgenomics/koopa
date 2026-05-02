"""Install metadata functions."""

from datetime import UTC, datetime
from json import dumps

from koopa.io import import_app_json
from koopa.os import os_id


def write_install_info(output_file: str, name: str, version: str) -> None:
    """Write install metadata JSON file."""
    json_data = import_app_json()
    sys_dict = {"os_id": os_id()}
    build_deps = []
    deps = []
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
    info = {
        "name": name,
        "version": version,
        "date": datetime.now(tz=UTC).strftime("%Y-%m-%d %H:%M:%S"),
        "os_id": sys_dict["os_id"],
        "build_dependencies": build_deps,
        "dependencies": deps,
    }
    with open(output_file, "w") as fh:
        fh.write(dumps(info, indent=2, sort_keys=False))
        fh.write("\n")
