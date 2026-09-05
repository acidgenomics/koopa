"""Install pcre2."""

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
    """Install pcre2.

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
        "--disable-dependency-tracking",
        "--disable-static",
        "--enable-jit",
        "--enable-pcre2-16",
        "--enable-pcre2-32",
        "--enable-pcre2grep-libbz2",
        "--enable-pcre2grep-libz",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("--enable-pcre2test-libedit")
    make_build(conf_args=conf_args, env=env)
