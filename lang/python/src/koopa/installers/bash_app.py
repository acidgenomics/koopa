"""Install bash."""

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
    """Install bash.

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
    conf_args = [
        f"--prefix={prefix}",
        "--with-curses",
        "--with-installed-readline",
        "--without-bash-malloc",
        "--disable-nls",
        "--disable-profiling",
        "--disable-help-builtin",
        "--disable-restricted",
    ]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = f"-DSSH_SOURCE_BASHRC {cflags}".strip()
    make_build(conf_args=conf_args, env=env)
