"""Install xorg-libxcb."""

from koopa.build import locate, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xorg-libxcb.

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
    python = locate("python3")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-devel-docs=no",
            "--enable-dri3",
            "--enable-ge",
            "--enable-selinux",
            "--enable-xevie",
            "--enable-xprint",
            f"--prefix={prefix}",
            "--with-doxygen=no",
            f"PYTHON={python}",
        ],
        env=env,
    )
