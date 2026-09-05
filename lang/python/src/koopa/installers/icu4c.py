"""Install icu4c."""

import os
from pathlib import Path

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install icu4c.

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
    download_extract_cd()
    if os.path.islink("LICENSE") and not os.path.exists("LICENSE"):
        os.unlink("LICENSE")
        Path("LICENSE").touch()
    os.chdir("source")
    env.ldflags.insert(0, f"-Wl,-rpath,{prefix}/lib")
    make_build(
        conf_args=[
            "--disable-samples",
            "--disable-static",
            "--disable-tests",
            "--enable-rpath",
            "--enable-shared",
            "--with-library-bits=64",
            f"--prefix={prefix}",
        ],
        env=env,
    )
