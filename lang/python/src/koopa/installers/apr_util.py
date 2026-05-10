"""Install apr-util."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install apr-util."""
    env = activate_app_deps()
    apr_pfx = app_prefix("apr")
    expat_pfx = app_prefix("expat")
    openssl_pfx = app_prefix("openssl")
    download_extract_cd()
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
