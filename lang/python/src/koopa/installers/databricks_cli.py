"""Install databricks-cli."""

import os
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import mkdir
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install databricks-cli.

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
    os_key = "darwin" if sys.platform == "darwin" else "linux"
    url = (
        f"https://github.com/databricks/cli/releases/download/v{version}/"
        f"databricks_cli_{version}_{os_key}_{arch2()}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, prefix)
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    os.replace(os.path.join(prefix, "databricks"), os.path.join(bin_dir, "databricks"))
