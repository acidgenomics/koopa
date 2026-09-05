"""Install r-gfortran."""

import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r-gfortran.

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
    url = f"https://mac.r-project.org/tools/gfortran-{version}-universal.pkg"
    pkg_file = download(url)
    subprocess.run(
        ["sudo", "installer", "-pkg", pkg_file, "-target", "/"],
        check=True,
    )
