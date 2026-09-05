"""Install libxml2."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libxml2.

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
            "--disable-dependency-tracking",
            "--enable-static=no",
            "--with-ftp",
            "--with-history",
            "--with-iconv",
            "--with-icu",
            "--with-legacy",
            "--with-lzma",
            "--with-readline",
            "--with-tls",
            "--with-zlib",
            "--without-python",
            f"--prefix={prefix}",
        ],
        env=env,
    )
