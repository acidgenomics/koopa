"""Install openldap."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install openldap."""
    env = activate_app("groff", build_only=True)
    env = activate_app("openssl", env=env)
    url = (
        f"https://www.openldap.org/software/download/OpenLDAP/"
        f"openldap-release/openldap-{version}.tgz"
    )
    download_extract_cd(url)
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
