"""Install rsync."""

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
    """Install rsync.

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
        "--disable-debug",
        "--enable-ipv6",
        "--enable-lz4",
        "--enable-openssl",
        "--enable-xxhash",
        "--with-included-popt=no",
        "--with-included-zlib=no",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("--disable-zstd")
    else:
        conf_args.append("--enable-zstd")
    make_build(conf_args=conf_args, env=env)
