"""Install go."""

import os
import subprocess
import sys

from koopa.download import download
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install go.

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
    arch = arch2()
    os_id = "darwin" if sys.platform == "darwin" else "linux"
    url = f"https://dl.google.com/go/go{version}.{os_id}-{arch}.tar.gz"
    tarball = download(url)
    os.makedirs(prefix, exist_ok=True)
    subprocess.run(
        ["tar", "-xf", tarball, "-C", prefix, "--strip-components=1"],
        check=True,
    )
