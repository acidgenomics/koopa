"""Install krb5."""

from __future__ import annotations

import os

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def _major_minor_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}.{parts[1]}"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install krb5."""
    env = activate_app("libedit", "openssl", env=None)
    mm = _major_minor_version(version)
    url = (
        f"https://kerberos.org/dist/krb5/"
        f"{mm}/krb5-{version}.tar.gz"
    )
    download_extract_cd(url)
    os.chdir(os.path.join("krb5", "src"))
    make_build(
        conf_args=[
            "--disable-nls",
            f"--prefix={prefix}",
            "--with-crypto-impl=openssl",
            "--with-libedit",
            "--without-keyutils",
            "--without-readline",
            "--without-system-verto",
        ],
        env=env,
    )
