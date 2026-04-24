"""System check functions."""

from os.path import basename, isdir, isfile, islink, join, realpath

from koopa.app import installed_apps
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
