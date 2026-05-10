"""Install ruby."""

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
    """Install ruby."""
    env = activate_app_deps()
    libffi_prefix = app_prefix("libffi")
    libyaml_prefix = app_prefix("libyaml")
    openssl_prefix = app_prefix("openssl3")
    readline_prefix = app_prefix("readline")
    zlib_prefix = app_prefix("zlib")
    download_extract_cd()
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
