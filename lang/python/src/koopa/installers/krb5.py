"""Install krb5."""

import os

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install krb5."""
    env = activate_app("libedit", "openssl", env=None)
    download_extract_cd()
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
