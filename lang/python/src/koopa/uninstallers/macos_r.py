"""Uninstall R framework on macOS."""

from __future__ import annotations

import os

from koopa.file_ops import rm
from koopa.uninstallers.macos_r_gfortran import main as uninstall_gfortran
from koopa.uninstallers.macos_r_xcode_openmp import main as uninstall_openmp


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall R framework on macOS."""
    framework = "/Library/Frameworks/R.framework"
    if not os.path.exists(framework):
        return
    system_paths = [
        "/Applications/R.app",
        "/Library/Frameworks/R.framework",
        "/opt/R",
        "/usr/local/bin/R",
        "/usr/local/bin/Rscript",
    ]
    for path in system_paths:
        if os.path.lexists(path):
            rm(path, sudo=True)
    uninstall_gfortran(
        name="r-gfortran",
        platform=platform,
        mode=mode,
        prefix=prefix,
        verbose=verbose,
    )
    uninstall_openmp(
        name="r-xcode-openmp",
        platform=platform,
        mode=mode,
        prefix=prefix,
        verbose=verbose,
    )
