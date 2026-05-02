"""Install R framework on macOS."""

from __future__ import annotations

import os
import subprocess

from koopa.download import download
from koopa.file_ops import mv
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
    r_arch = "arm64" if machine == "aarch64" else machine
    os_string = "big-sur"
    maj_min_ver = ".".join(version.split(".")[:2])
    r_prefix = f"{framework_prefix}/Versions/{maj_min_ver}-{r_arch}/Resources"
    site_library = os.path.join(r_prefix, "site-library")
    backup = os.path.isdir(site_library)
    if backup:
        mv(site_library, "site-library")
    url = (
        f"https://cran.r-project.org/bin/macosx/{os_string}-{r_arch}/base/R-{version}-{r_arch}.pkg"
    )
    pkg_file = download(url)
    subprocess.run(
        ["sudo", "installer", "-pkg", pkg_file, "-target", "/"],
        check=True,
    )
    if not os.path.isdir(r_prefix):
        msg = f"R prefix not found: {r_prefix}"
        raise RuntimeError(msg)
    if backup:
        mv("site-library", site_library)
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
