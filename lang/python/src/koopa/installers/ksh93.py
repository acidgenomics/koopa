"""Install ksh93."""

import os
import subprocess

from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ksh93.

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
    download_extract_cd()
    subprocess.run(
        [
            "bin/package",
            "make",
            *(["VERBOSE=1"] if os.environ.get("KOOPA_VERBOSE") == "1" else []),
        ],
        check=True,
    )
    subprocess.run(
        ["bin/package", "install", prefix],
        check=True,
    )
