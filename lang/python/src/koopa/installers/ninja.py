"""Install ninja."""

import os
import shutil
import subprocess

from koopa.build import locate
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ninja.

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
    python = locate("python3")
    download_extract_cd()
    subprocess.run(
        [python, "configure.py", "--bootstrap"],
        env=env.to_env_dict(),
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    shutil.copy2("ninja", os.path.join(bin_dir, "ninja"))
