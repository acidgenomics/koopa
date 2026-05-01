"""Install openssh."""

from __future__ import annotations

import os
import sys

from koopa.build import activate_app, app_prefix, make_build
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install openssh."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app(
        "zlib",
        "openssl",
        "ldns",
        "libedit",
        "libfido2",
        "libxcrypt",
        "krb5",
        env=env,
    )
    openssl_prefix = app_prefix("openssl")
    libedit_prefix = app_prefix("libedit")
    url = f"https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [
        f"--mandir={prefix}/share/man",
        f"--prefix={prefix}",
        f"--sbindir={prefix}/bin",
        f"--sysconfdir={prefix}/etc/ssh",
        "--with-kerberos5",
        "--with-ldns",
        "--with-md5-passwords",
        f"--with-pid-dir={prefix}/var/run",
        "--with-security-key-builtin",
        f"--with-ssl-dir={openssl_prefix}",
        "--with-zlib",
        "--without-xauth",
        "--without-zlib-version-check",
    ]
    if sys.platform == "darwin":
        conf_args.extend(
            [
                f"--with-libedit={libedit_prefix}",
                "--with-keychain=apple",
                "--with-privsep-path=/var/empty",
            ]
        )
    else:
        conf_args.extend(
            [
                "--with-libedit",
                f"--with-privsep-path={prefix}/var/lib/sshd",
            ]
        )
    make_build(
        conf_args=conf_args,
        targets=["install-nokeys"],
        env=env,
    )
    bin_dir = os.path.join(prefix, "bin")
    slogin = os.path.join(bin_dir, "slogin")
    if os.path.exists(slogin):
        ln(slogin, os.path.join(bin_dir, "ssh"))
