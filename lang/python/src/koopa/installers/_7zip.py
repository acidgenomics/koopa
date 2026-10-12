"""Install 7-Zip."""

import os
import shutil
import subprocess
import sys
from glob import glob

from koopa.build import locate
from koopa.installers._build_helper import activate_app_deps, download_extract_cd
from koopa.system import cpu_count


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install 7-Zip.

    Builds the console ``7zz`` binary from the official source archive and
    links ``7z`` and ``7za`` to it, so scripts written for p7zip keep working.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    env = activate_app_deps()
    make = locate("make")
    download_extract_cd()
    os.chdir("CPP/7zip/Bundles/Alone2")
    if sys.platform == "darwin":
        makefile = "cmpl_mac_arm64.mak"
    else:
        makefile = "cmpl_gcc.mak"
    subprocess.run(
        [make, f"--jobs={cpu_count()}", "-f", f"../../{makefile}"],
        env=env.to_env_dict(),
        check=True,
    )
    binary = glob("b/*/7zz")[0]
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    shutil.copy2(binary, os.path.join(bin_dir, "7zz"))
    for link in ("7z", "7za"):
        os.symlink("7zz", os.path.join(bin_dir, link))
