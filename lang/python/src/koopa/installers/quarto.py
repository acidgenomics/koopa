"""Install quarto."""

import sys

from koopa.archive import extract
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install quarto.

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
    if sys.platform == "darwin":
        slug = "macos"
    else:
        slug = "linux-amd64"
    url = (
        f"https://github.com/quarto-dev/quarto-cli/releases/download/"
        f"v{version}/quarto-{version}-{slug}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, prefix)
