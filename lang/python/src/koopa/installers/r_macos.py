"""Install R framework on macOS."""

from __future__ import annotations

import os
import shutil
import subprocess
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
    machine = arch()
    if machine in ("aarch64", "arm64"):
        r_arch = "arm64"
        os_string = "sonoma"
    else:
        r_arch = machine
        os_string = "big-sur"
    maj_min_ver = ".".join(version.split(".")[:2])
    r_prefix = f"{framework_prefix}/Versions/{maj_min_ver}-{r_arch}/Resources"
    site_library = os.path.join(r_prefix, "site-library")
    backup_dir = ""
    if os.path.isdir(site_library):
        backup_dir = tempfile.mkdtemp(prefix="koopa-r-site-library-")
        backup_path = os.path.join(backup_dir, "site-library")
        shutil.move(site_library, backup_path)
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
        if not os.path.isdir(r_prefix):
            msg = f"R prefix not found: {r_prefix}"
            raise RuntimeError(msg)
        if backup_dir:
            shutil.move(os.path.join(backup_dir, "site-library"), site_library)
    except BaseException:
        if backup_dir and os.path.isdir(os.path.join(backup_dir, "site-library")):
            shutil.move(os.path.join(backup_dir, "site-library"), site_library)
        raise
    finally:
        if backup_dir and os.path.isdir(backup_dir):
            shutil.rmtree(backup_dir, ignore_errors=True)
    r_bin = os.path.join(r_prefix, "bin", "R")
    if not os.path.isfile(r_bin):
        msg = f"R binary not found: {r_bin}"
        raise RuntimeError(msg)
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
    subprocess.run(
        ["koopa", "configure", "r", r_bin],
        check=True,
    )
