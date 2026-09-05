"""Install xorg-xcb-proto."""

from koopa.build import locate, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xorg-xcb-proto.

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
            "--disable-silent-rules",
            f"--prefix={prefix}",
            f"PYTHON={python}",
        ],
        env=env,
    )
