"""Install nmap."""

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
    """Install nmap."""
    env = activate_app_deps()
    liblinear_prefix = app_prefix("liblinear")
    libpcap_prefix = app_prefix("libpcap")
    libssh2_prefix = app_prefix("libssh2")
    openssl_prefix = app_prefix("openssl")
    pcre2_prefix = app_prefix("pcre2")
    zlib_prefix = app_prefix("zlib")
    download_extract_cd()
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
