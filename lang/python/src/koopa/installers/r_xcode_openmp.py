"""Install r-xcode-openmp."""

import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r-xcode-openmp.

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
    url = f"https://mac.r-project.org/openmp/openmp-{version}-darwin20-Release.tar.gz"
    tar_file = download(url)
    subprocess.run(
        ["sudo", "tar", "fxz", tar_file, "-C", "/"],
        check=True,
    )
