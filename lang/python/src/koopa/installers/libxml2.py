"""Install libxml2."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def _major_minor_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}.{parts[1]}"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libxml2."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app(
        "zlib", "icu4c", "readline", "xz", "libiconv", env=env
    )
    mm = _major_minor_version(version)
    url = (
        f"https://download.gnome.org/sources/libxml2/"
        f"{mm}/libxml2-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--enable-static=no",
            "--with-ftp",
            "--with-history",
            "--with-iconv",
            "--with-icu",
            "--with-legacy",
            "--with-lzma",
            "--with-readline",
            "--with-tls",
            "--with-zlib",
            "--without-python",
            f"--prefix={prefix}",
        ],
        env=env,
    )
