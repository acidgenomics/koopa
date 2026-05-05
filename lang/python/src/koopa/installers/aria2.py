"""Install aria2."""

import sys

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install aria2."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app(
        "zlib",
        "gettext",
        "openssl",
        "libssh2",
        "icu4c",
        "libxml2",
        "sqlite",
        env=env,
    )
    download_extract_cd()
    conf_args = [
        "--disable-bittorrent",
        "--disable-dependency-tracking",
        "--disable-metalink",
        "--with-libssh2",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.extend(
            [
                "--with-appletls",
                "--without-gnutls",
                "--without-libgcrypt",
                "--without-libgmp",
                "--without-libnettle",
                "--without-openssl",
            ]
        )
    else:
        conf_args.extend(
            [
                "--with-openssl",
                "--without-appletls",
                "--without-gnutls",
                "--without-libgcrypt",
                "--without-libgmp",
                "--without-libnettle",
            ]
        )
    make_build(conf_args=conf_args, env=env)
