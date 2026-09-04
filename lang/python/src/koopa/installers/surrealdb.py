"""Install surrealdb."""

import os
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install surrealdb.

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
    machine = arch2()
    if sys.platform == "darwin":
        platform_slug = f"darwin-{machine}"
    else:
        platform_slug = f"linux-{machine}"
    url = (
        f"https://github.com/surrealdb/surrealdb/releases/download/"
        f"v{version}/surreal-v{version}.{platform_slug}.tgz"
    )
    tarball = download(url)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    extract(tarball, bin_dir)
