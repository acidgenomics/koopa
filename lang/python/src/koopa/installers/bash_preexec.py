"""Install bash-preexec."""

import os
import shutil

from koopa.download import download
from koopa.installers._build_helper import _resolve_src_url


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bash-preexec.

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
    url = _resolve_src_url(name, version)
    script = download(url, "bash-preexec.sh")
    share_dir = os.path.join(prefix, "share", "bash-preexec")
    os.makedirs(share_dir, exist_ok=True)
    shutil.copy2(script, os.path.join(share_dir, "bash-preexec.sh"))
