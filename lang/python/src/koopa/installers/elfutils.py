"""Install elfutils."""

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
    """Install elfutils."""
    env = activate_app_deps()
    gettext_prefix = app_prefix("gettext")
    libiconv_prefix = app_prefix("libiconv")
    conf_args = [
        f"--prefix={prefix}",
        "--disable-debuginfod",
        "--disable-debugpred",
        "--disable-dependency-tracking",
        "--disable-libdebuginfod",
        "--disable-silent-rules",
        "--program-prefix=eu-",
        "--with-bzlib",
        f"--with-libiconv-prefix={libiconv_prefix}",
        "--with-lzma",
        "--with-zlib",
        "--with-zstd",
    ]
    if sys.platform == "darwin":
        conf_args.append(f"--with-libintl-prefix={gettext_prefix}")
    download_extract_cd()
    make_build(conf_args=conf_args, env=env)
