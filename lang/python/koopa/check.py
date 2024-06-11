"""
System check functions.
Updated 2024-05-28.
"""

from os.path import basename, isdir, islink, join, realpath

from koopa.app import installed_apps
from koopa.io import import_app_json
from koopa.os import koopa_opt_prefix


def check_installed_apps() -> bool:
    """
    Check system integrity.
    Updated 2024-05-31.
    """
    ok = True
    opt_prefix = koopa_opt_prefix()
    json_data = import_app_json()
    names = installed_apps()
    for name in names:
        if name not in json_data.keys():
            raise ValueError(f"Unsupported app: {name!r}.")
        path = join(opt_prefix, name)
        assert islink(path)
        path = realpath(path)
        assert isdir(path)
        linked_ver = basename(path)
        if "removed" in json_data[name].keys() and json_data[name]["removed"]:
            ok = False
            print(f"{name} (removed)")
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
