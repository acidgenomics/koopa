"""Install apr-util."""

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
    """Install apr-util."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("apr", "expat", "openssl", env=env)
    apr_pfx = app_prefix("apr")
    expat_pfx = app_prefix("expat")
    openssl_pfx = app_prefix("openssl")
    url = f"https://archive.apache.org/dist/apr/apr-util-{version}.tar.bz2"
    download_extract_cd(url)
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            f"--with-apr={apr_pfx}/bin/apr-1-config",
            "--with-crypto",
            f"--with-expat={expat_pfx}",
            f"--with-openssl={openssl_pfx}",
            "--without-pgsql",
            "--without-sqlite3",
        ],
        env=env,
    )
