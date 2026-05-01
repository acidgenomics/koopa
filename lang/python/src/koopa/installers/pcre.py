"""Install pcre."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pcre."""
    env = activate_app(
        "autoconf", "automake", "libtool", "pkg-config", build_only=True
    )
    env = activate_app("zlib", "bzip2", env=env)
    url = f"https://koopa.acidgenomics.com/src/pcre/{version}.tar.bz2"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-static",
            "--enable-pcre16",
            "--enable-pcre32",
            "--enable-pcre8",
            "--enable-pcregrep-libbz2",
            "--enable-pcregrep-libz",
            "--enable-unicode-properties",
            "--enable-utf8",
            f"--prefix={prefix}",
        ],
        env=env,
    )
