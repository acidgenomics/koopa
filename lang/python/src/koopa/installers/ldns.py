"""Install ldns."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ldns."""
    env = activate_app("openssl", env=None)
    openssl_prefix = app_prefix("openssl")
    url = f"https://nlnetlabs.nl/downloads/ldns/ldns-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            f"--with-ssl={openssl_prefix}",
            "--without-drill",
            "--without-examples",
            "--without-pyldns",
            "--without-pyldnsx",
            "--without-xcode-sdk",
        ],
        env=env,
    )
