"""Configure rstudio-server."""

from __future__ import annotations

import os
import shutil
import subprocess

from koopa.file_ops import write_string


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure RStudio Server.

    Locates system R and Rscript, gets LD_LIBRARY_PATH from R, and writes
    /etc/rstudio/rserver.conf.
    """
    r_bin = shutil.which("R")
    rscript_bin = shutil.which("Rscript")
    if r_bin is None:
        msg = "System R not found."
        raise FileNotFoundError(msg)
    if rscript_bin is None:
        msg = "System Rscript not found."
        raise FileNotFoundError(msg)
    r_bin = os.path.realpath(r_bin)
    # Get LD_LIBRARY_PATH from R.
    result = subprocess.run(
        [rscript_bin, "-e", 'cat(Sys.getenv("LD_LIBRARY_PATH"))'],
        capture_output=True,
        text=True,
        check=True,
    )
    ld_library_path = result.stdout.strip()
    if not ld_library_path:
        msg = "Failed to get LD_LIBRARY_PATH from R."
        raise RuntimeError(msg)
    # Build config lines.
    conf_lines: list[str] = []
    if os.geteuid() == 0:
        conf_lines.append("auth-minimum-user-id=0")
        conf_lines.append("auth-none=1")
    conf_lines.append(f"rsession-ld-library-path={ld_library_path}")
    conf_lines.append(f"rsession-which-r={r_bin}")
    conf_string = "\n".join(conf_lines) + "\n"
    conf_file = "/etc/rstudio/rserver.conf"
    write_string(conf_string, conf_file, sudo=True)
