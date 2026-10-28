"""Install jfrog-cli."""

import os
import stat
import sys

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
    """Install jfrog-cli.

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
    os_key = "mac" if sys.platform == "darwin" else "linux"
    url = (
        f"https://releases.jfrog.io/artifactory/jfrog-cli/v2-jf/{version}/"
        f"jfrog-cli-{os_key}-{arch2()}/jf"
    )
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    dest = os.path.join(bin_dir, "jf")
    download(url, dest)
    os.chmod(dest, os.stat(dest).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
