"""Install tar."""

import os
import sys

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tar.

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
    env = activate_app_deps()
    download_extract_cd()
    os.environ["FORCE_UNSAFE_CONFIGURE"] = "1"
    conf_args = [
        "--disable-nls",
        "--program-prefix=g",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("LIBS=-liconv")
    make_build(conf_args=conf_args, env=env)
