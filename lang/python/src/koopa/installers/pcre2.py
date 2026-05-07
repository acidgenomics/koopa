"""Install pcre2."""

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
    """Install pcre2."""
    env = activate_app("autoconf", "automake", "libtool", "pkg-config", build_only=True)
    deps = ["zlib"]
    if sys.platform != "darwin":
        deps.append("bzip2")
    else:
        deps.append("libedit")
    env = activate_app(*deps, env=env)
    download_extract_cd()
    conf_args = [
        "--disable-dependency-tracking",
        "--disable-static",
        "--enable-jit",
        "--enable-pcre2-16",
        "--enable-pcre2-32",
        "--enable-pcre2grep-libbz2",
        "--enable-pcre2grep-libz",
        f"--prefix={prefix}",
    ]
    if sys.platform == "darwin":
        conf_args.append("--enable-pcre2test-libedit")
    make_build(conf_args=conf_args, env=env)
