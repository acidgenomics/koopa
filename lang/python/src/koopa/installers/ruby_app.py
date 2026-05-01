"""Install ruby."""

from __future__ import annotations

import sys

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ruby."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "openssl", "readline", "libyaml", "libffi", env=env)
    libffi_prefix = app_prefix("libffi")
    libyaml_prefix = app_prefix("libyaml")
    openssl_prefix = app_prefix("openssl")
    readline_prefix = app_prefix("readline")
    zlib_prefix = app_prefix("zlib")
    maj_min_ver = major_minor_version(version)
    url = f"https://cache.ruby-lang.org/pub/ruby/{maj_min_ver}/ruby-{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [
        "--disable-install-doc",
        "--disable-silent-rules",
        "--enable-load-relative",
        "--enable-shared",
        f"--prefix={prefix}",
        f"--with-libffi-dir={libffi_prefix}",
        f"--with-libyaml-dir={libyaml_prefix}",
        f"--with-openssl-dir={openssl_prefix}",
        f"--with-readline-dir={readline_prefix}",
        f"--with-zlib-dir={zlib_prefix}",
        "--without-gmp",
    ]
    if sys.platform == "darwin":
        conf_args.append("--enable-dtrace")
    make_build(conf_args=conf_args, env=env)
