"""Install curl."""

import sys

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install curl."""
    env = activate_app_deps()
    ca_prefix = app_prefix("ca-certificates")
    ca_bundle = f"{ca_prefix}/share/ca-certificates/cacert.pem"
    download_extract_cd()
    conf_args = [
        "--disable-debug",
        "--disable-ldap",
        "--disable-static",
        "--enable-threaded-resolver",
        "--enable-versioned-symbols",
        f"--with-ca-bundle={ca_bundle}",
        "--with-libssh2",
        "--with-openssl",
        "--with-zlib",
        "--without-zstd",
        "--without-ca-path",
        "--without-gssapi",
        "--without-libidn2",
        "--without-libpsl",
        "--without-librtmp",
        "--with-nghttp2",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.extend(
            [
                "--with-default-ssl-backend=openssl",
                "--without-secure-transport",
            ]
        )
    make_build(conf_args=conf_args, env=env)
