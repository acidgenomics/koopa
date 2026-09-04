"""Install zip."""

import subprocess

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
    """Install zip.

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
    subprocess_env = env.to_env_dict()
    jobs = cpu_count()
    subprocess.run(
        [make, f"--jobs={jobs}", "-f", "unix/Makefile", "generic"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            "-f",
            "unix/Makefile",
            "install",
            f"prefix={prefix}",
            f"MANDIR={prefix}/share/man/man1",
        ],
        env=subprocess_env,
        check=True,
    )
