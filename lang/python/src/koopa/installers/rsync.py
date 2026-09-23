"""Install rsync."""

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
        # rsync 3.5.1 added IDN support and now probes idn2.h by default,
        # aborting configure entirely when it is absent. No koopa app
        # provides libidn2 for rsync's default build, so disable it.
        "--disable-idn",
        "--enable-ipv6",
        "--enable-lz4",
        "--enable-openssl",
        "--enable-xxhash",
        "--enable-zstd",
        "--with-included-popt=no",
        "--with-included-zlib=no",
        f"--prefix={prefix}",
    ]
    make_build(conf_args=conf_args, env=env)
