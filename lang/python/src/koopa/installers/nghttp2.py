"""Install nghttp2."""

from __future__ import annotations

import sys

from koopa.build import activate_app, locate, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nghttp2."""
    build_deps = ["pkg-config", "python"]
    if sys.platform != "darwin":
        build_deps.append("gcc")
    env = activate_app(*build_deps, build_only=True)
    env = activate_app(
        "c-ares",
        "icu4c",
        "libxml2",
        "openssl",
        "zlib",
        env=env,
    )
    python = locate("python3")
    url = (
        f"https://github.com/nghttp2/nghttp2/releases/download/v{version}/nghttp2-{version}.tar.gz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-examples",
            "--disable-hpack-tools",
            "--disable-silent-rules",
            "--disable-static",
            "--with-libcares",
            "--with-libxml2",
            "--with-openssl",
            "--with-zlib",
            "--without-systemd",
            f"PYTHON={python}",
            f"--prefix={prefix}",
        ],
        env=env,
    )
