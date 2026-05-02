"""Configure R."""

from __future__ import annotations

import grp
import os
import pwd
import subprocess
import sys

from koopa.r import (
    configure_r_environ,
    r_configure_ldpaths,
    r_copy_files_into_etc,
    r_prefix,
)


def _find_r_cmd(mode: str) -> str:
    """Locate R binary for the given mode."""
    if mode == "system":
        if sys.platform == "darwin":
            framework = "/Library/Frameworks/R.framework/Resources/bin/R"
            if os.path.isfile(framework):
                return framework
        for candidate in ("/usr/bin/R", "/usr/local/bin/R"):
            if os.path.isfile(candidate):
                return candidate
    else:
        from koopa.prefix import app_prefix

        r_app = os.path.join(app_prefix("r"), "bin", "R")
        if os.path.isfile(r_app):
            return r_app
    import shutil

    r = shutil.which("R")
    if r is not None:
        return r
    msg = "R binary not found."
    raise FileNotFoundError(msg)


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure R."""
    r_cmd = _find_r_cmd(mode)
    r_home = r_prefix(r_cmd)
    is_system = mode == "system"
    site_library = os.path.join(r_home, "site-library")
    if is_system:
        if not os.path.isdir(site_library):
            subprocess.run(
                ["sudo", "mkdir", "-p", site_library],
                check=True,
            )
        user = pwd.getpwuid(os.getuid()).pw_name
        group = grp.getgrgid(os.getgid()).gr_name
        subprocess.run(
            ["sudo", "chown", "-R", f"{user}:{group}", site_library],
            check=True,
        )
        subprocess.run(
            ["sudo", "chmod", "-R", "g+rw", site_library],
            check=True,
        )
    else:
        os.makedirs(site_library, exist_ok=True)
    configure_r_environ(r_home)
    r_configure_ldpaths(r_cmd)
    r_copy_files_into_etc(r_cmd)
    if is_system:
        subprocess.run(
            ["sudo", "chown", "-R", f"{user}:{group}", site_library],
            check=True,
        )
        subprocess.run(
            ["sudo", "chmod", "-R", "g+rw", site_library],
            check=True,
        )
