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
    Updated 2024-05-28.
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
        current_ver = json_data[name]["version"]
        # FIXME Need to sanitize hash version (e.g. for dotfiles)
        if linked_ver == current_ver:
            continue
        print(f"{name} ({linked_ver} != {current_ver})")
        ok = False
    return ok
