"""Install openldap."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install openldap.

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
            "--enable-accesslog",
            "--enable-auditlog",
            "--enable-bdb=no",
            "--enable-constraint",
            "--enable-dds",
            "--enable-deref",
            "--enable-dyngroup",
            "--enable-dynlist",
            "--enable-hdb=no",
            "--enable-memberof",
            "--enable-ppolicy",
            "--enable-proxycache",
            "--enable-refint",
            "--enable-retcode",
            "--enable-seqmod",
            "--enable-translucent",
            "--enable-unique",
            "--enable-valsort",
            "--without-systemd",
            f"--prefix={prefix}",
        ],
        env=env,
    )
