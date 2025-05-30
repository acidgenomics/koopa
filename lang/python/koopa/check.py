"""
System check functions.
Updated 2025-05-08.
"""

from os.path import basename, isdir, islink, join, realpath

from koopa.app import installed_apps
from koopa.io import import_app_json
from koopa.os import koopa_opt_prefix


def check_installed_apps() -> bool:
    """
    Check system integrity.
    Updated 2025-05-08.
    """
    ok = True
    opt_prefix = koopa_opt_prefix()
    json_data = import_app_json()
    names = installed_apps()
    for name in names:
        if name not in json_data.keys():
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
        if "removed" in json_data[name].keys() and json_data[name]["removed"]:
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
