"""Install gnupg."""

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
    """Install gnupg."""
    env = activate_app("pkg-config", build_only=True)
    deps = [
        "zlib", "readline", "nettle", "libtasn1", "gnutls", "sqlite",
        "libgpg-error", "libgcrypt", "libassuan", "libksba", "npth",
        "pinentry", "openldap", "libiconv",
    ]
    if sys.platform != "darwin":
        deps.append("bzip2")
    env = activate_app(*deps, env=env)
    lgpe_prefix = app_prefix("libgpg-error")
    libgcrypt_prefix = app_prefix("libgcrypt")
    libassuan_prefix = app_prefix("libassuan")
    libksba_prefix = app_prefix("libksba")
    npth_prefix = app_prefix("npth")
    pinentry_prefix = app_prefix("pinentry")
    gcrypt_url = "https://gnupg.org/ftp/gcrypt"
    url = f"{gcrypt_url}/gnupg/gnupg-{version}.tar.bz2"
    download_extract_cd(url)
    conf_args = [
        "--enable-gnutls",
        f"--prefix={prefix}",
        "--with-readline",
        "--with-zlib",
        f"--with-libassuan-prefix={libassuan_prefix}",
        f"--with-libgcrypt-prefix={libgcrypt_prefix}",
        f"--with-libgpg-error-prefix={lgpe_prefix}",
        f"--with-libksba-prefix={libksba_prefix}",
        f"--with-npth-prefix={npth_prefix}",
        f"--with-pinentry-pgm={pinentry_prefix}/bin/pinentry",
    ]
    if sys.platform != "darwin":
        conf_args.append("--with-bzip2")
    make_build(conf_args=conf_args, env=env)
