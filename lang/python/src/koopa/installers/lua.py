"""Install lua."""

import subprocess
import sys

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
    """Install lua.

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
    platform = "macosx" if sys.platform == "darwin" else "linux"
    subprocess_env = env.to_env_dict()
    jobs = cpu_count()
    subprocess.run(
        [make, f"--jobs={jobs}", platform],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install", f"INSTALL_TOP={prefix}"],
        env=subprocess_env,
        check=True,
    )
