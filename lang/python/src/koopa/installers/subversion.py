"""Install subversion."""

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
    """Install subversion."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app(
        "zlib",
        "apr",
        "apr-util",
        "openssl",
        "perl",
        "python",
        "ruby",
        "serf",
        "sqlite",
        env=env,
    )
    apr_prefix = app_prefix("apr")
    apr_util_prefix = app_prefix("apr-util")
    serf_prefix = app_prefix("serf")
    sqlite_prefix = app_prefix("sqlite")
    url = f"https://archive.apache.org/dist/subversion/subversion-{version}.tar.bz2"
    download_extract_cd(url)
    conf_args = [
        "--disable-debug",
        "--disable-mod-activation",
        "--disable-plaintext-password-storage",
        "--disable-static",
        "--enable-optimize",
        f"--prefix={prefix}",
        f"--with-apr={apr_prefix}",
        f"--with-apr-util={apr_util_prefix}",
        "--with-apxs=no",
        "--with-lz4=internal",
        f"--with-serf={serf_prefix}",
        f"--with-sqlite={sqlite_prefix}",
        "--with-utf8proc=internal",
        "--without-apache-libexecdir",
        "--without-berkeley-db",
        "--without-gpg-agent",
        "--without-jikes",
        "--without-swig",
    ]
    make_build(conf_args=conf_args, env=env)
