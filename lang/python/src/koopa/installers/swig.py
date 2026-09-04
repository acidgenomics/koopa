"""Install swig."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install swig.

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
    pcre2_prefix = app_prefix("pcre2")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            f"--prefix={prefix}",
            f"--with-pcre2-prefix={pcre2_prefix}",
            "--without-alllang",
        ],
        env=env,
    )
