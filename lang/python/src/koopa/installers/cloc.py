"""Install cloc."""

import os
import stat

from koopa.download import download
from koopa.file_ops import mkdir


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install cloc.

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
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    url = f"https://github.com/AlDanial/cloc/releases/download/v{version}/cloc-{version}.pl"
    dest = os.path.join(bin_dir, "cloc")
    download(url, dest)
    os.chmod(dest, os.stat(dest).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
