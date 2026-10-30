"""Install Vim from source without relying on Conda's Homebrew-linked binary."""

import os
import subprocess

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd
from koopa.system import is_linux


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Vim and verify that the resulting executable starts.

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
    make_build(
        conf_args=[
            "--enable-cscope",
            "--enable-gui=no",
            "--enable-perlinterp=yes",
            "--enable-pythoninterp=no",
            "--enable-python3interp=yes",
            "--with-features=huge",
            f"--with-python3-command={app_prefix('python3.14')}/bin/python3.14",
            "--with-tlib=ncursesw",
            "--with-x" if is_linux() else "--without-x",
            "--without-local-dir",
            f"--prefix={prefix}",
        ],
        env=env,
    )
    subprocess.run(
        [os.path.join(prefix, "bin", "vim"), "--version"],
        check=True,
        capture_output=True,
        text=True,
    )
