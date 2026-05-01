"""Install postgresql."""

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
    """Install postgresql."""
    env = activate_app("bison", "flex", "pkg-config", build_only=True)
    env = activate_app(
        "icu4c",
        "libxml2",
        "libxslt",
        "lz4",
        "openssl",
        "perl",
        "readline",
        env=env,
    )
    url = f"https://ftp.postgresql.org/pub/source/v{version}/postgresql-{version}.tar.bz2"
    download_extract_cd(url)
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            "--disable-debug",
            "--enable-thread-safety",
            "--with-icu",
            "--with-libxml",
            "--with-libxslt",
            "--with-lz4",
            "--with-openssl",
            "--with-perl",
            "--without-gssapi",
            "--without-ldap",
            "--without-pam",
        ],
        env=env,
    )
