"""Install curl."""

from __future__ import annotations

import sys

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install curl."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("ca-certificates", "zlib", "zstd", "openssl", "libssh2", env=env)
    ca_prefix = app_prefix("ca-certificates")
    ca_bundle = f"{ca_prefix}/share/ca-certificates/cacert.pem"
    version2 = version.replace(".", "_")
    url = f"https://github.com/curl/curl/releases/download/curl-{version2}/curl-{version}.tar.xz"
    download_extract_cd(url)
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
        "--with-zstd",
        "--without-ca-path",
        "--without-gssapi",
        "--without-libidn2",
        "--without-libpsl",
        "--without-librtmp",
        "--without-nghttp2",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.extend(
            [
                "--with-default-ssl-backend=openssl",
                "--with-secure-transport",
            ]
        )
    make_build(conf_args=conf_args, env=env)
