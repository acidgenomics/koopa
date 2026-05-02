"""Install elfutils."""

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
    """Install elfutils."""
    deps: list[str] = []
    if sys.platform != "darwin":
        deps.append("bzip2")
    deps.extend(["xz", "zlib", "zstd"])
    if sys.platform == "darwin":
        deps.append("gettext")
    deps.append("libiconv")
    env = activate_app("m4", build_only=True)
    env = activate_app(*deps, env=env)
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
    url = f"https://sourceware.org/elfutils/ftp/{version}/elfutils-{version}.tar.bz2"
    download_extract_cd(url)
    make_build(conf_args=conf_args, env=env)
