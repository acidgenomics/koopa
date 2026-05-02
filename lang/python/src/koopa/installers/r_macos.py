"""Install R framework on macOS."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile

from koopa.download import download
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install R framework on macOS."""
    framework_prefix = "/Library/Frameworks/R.framework"
    print(f"Target: {framework_prefix}", file=sys.stderr)
    machine = arch()
    if machine in ("aarch64", "arm64"):
        r_arch = "arm64"
        os_string = "sonoma"
    else:
        r_arch = machine
        os_string = "big-sur"
    maj_min_ver = ".".join(version.split(".")[:2])
    versions_prefix = os.path.join(framework_prefix, "Versions")
    r_prefix_candidates = [
        os.path.join(versions_prefix, maj_min_ver, "Resources"),
        os.path.join(versions_prefix, f"{maj_min_ver}-{r_arch}", "Resources"),
    ]
    backup_dir = ""
    backup_site_library_src = ""
    for candidate in r_prefix_candidates:
        sl = os.path.join(candidate, "site-library")
        if os.path.isdir(sl):
            backup_dir = tempfile.mkdtemp(prefix="koopa-r-site-library-")
            shutil.move(sl, os.path.join(backup_dir, "site-library"))
            backup_site_library_src = sl
            break
    try:
        url = (
            f"https://cran.r-project.org/bin/macosx/"
            f"{os_string}-{r_arch}/base/R-{version}-{r_arch}.pkg"
        )
        pkg_file = download(url)
        subprocess.run(
            ["sudo", "installer", "-pkg", pkg_file, "-target", "/"],
            check=True,
        )
        r_prefix = ""
        for candidate in r_prefix_candidates:
            if os.path.isdir(candidate):
                r_prefix = candidate
                break
        if not r_prefix:
            msg = f"R prefix not found at any of: {r_prefix_candidates}"
            raise RuntimeError(msg)
        site_library = os.path.join(r_prefix, "site-library")
        if backup_dir:
            shutil.move(os.path.join(backup_dir, "site-library"), site_library)
    except BaseException:
        if backup_dir and os.path.isdir(os.path.join(backup_dir, "site-library")):
            restore = backup_site_library_src or site_library
            shutil.move(os.path.join(backup_dir, "site-library"), restore)
        raise
    finally:
        if backup_dir and os.path.isdir(backup_dir):
            shutil.rmtree(backup_dir, ignore_errors=True)
    r_bin = os.path.join(r_prefix, "bin", "R")
    if not os.path.isfile(r_bin):
        msg = f"R binary not found: {r_bin}"
        raise RuntimeError(msg)
    current_version_dir = os.path.dirname(r_prefix)
    if os.path.isdir(versions_prefix):
        for entry in os.listdir(versions_prefix):
            entry_path = os.path.join(versions_prefix, entry)
            if entry_path == current_version_dir:
                continue
            if os.path.islink(entry_path):
                continue
            if not os.path.isdir(entry_path):
                continue
            print(f"Removing old version: {entry_path}", file=sys.stderr)
            subprocess.run(
                ["sudo", "rm", "-rf", entry_path],
                check=True,
            )
    if not os.path.isdir("/opt/gfortran"):
        subprocess.run(
            ["koopa", "macos", "install-system", "r-gfortran"],
            check=True,
        )
    if not os.path.isfile("/usr/local/include/omp.h"):
        subprocess.run(
            ["koopa", "macos", "install-system", "r-xcode-openmp"],
            check=True,
        )
    from koopa.configure import ConfigureConfig, configure_app

    configure_app(ConfigureConfig(name="r", mode="system"))
