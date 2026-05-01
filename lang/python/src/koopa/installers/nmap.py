"""Install nmap."""

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
    """Install nmap."""
    env = activate_app("pkg-config", build_only=True)
    deps = ["liblinear", "libpcap", "libssh2", "openssl", "pcre2", "zlib"]
    if sys.platform == "darwin":
        deps.append("lua")
    env = activate_app(*deps, env=env)
    liblinear_prefix = app_prefix("liblinear")
    libpcap_prefix = app_prefix("libpcap")
    libssh2_prefix = app_prefix("libssh2")
    openssl_prefix = app_prefix("openssl")
    pcre2_prefix = app_prefix("pcre2")
    zlib_prefix = app_prefix("zlib")
    url = f"https://nmap.org/dist/nmap-{version}.tar.bz2"
    download_extract_cd(url)
    conf_args = [
        f"--prefix={prefix}",
        "--disable-nmap-update",
        "--without-zenmap",
        f"--with-liblinear={liblinear_prefix}",
        f"--with-libpcap={libpcap_prefix}",
        f"--with-libssh2={libssh2_prefix}",
        f"--with-openssl={openssl_prefix}",
        f"--with-libpcre={pcre2_prefix}",
        f"--with-libz={zlib_prefix}",
    ]
    if sys.platform == "darwin":
        lua_prefix = app_prefix("lua")
        conf_args.append(f"--with-liblua={lua_prefix}")
    make_build(conf_args=conf_args, env=env)
