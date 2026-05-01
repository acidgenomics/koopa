"""Install pkgconf."""

from __future__ import annotations

import sys

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pkgconf."""
    url = f"https://distfiles.ariadne.space/pkgconf/pkgconf-{version}.tar.xz"
    download_extract_cd(url)
    if sys.platform == "darwin":
        sys_lib_dir = "/usr/lib"
        pc_path = "/usr/lib/pkgconfig"
    else:
        sys_lib_dir = "/usr/lib"
        pc_path = ":".join(
            [
                "/usr/lib/pkgconfig",
                "/usr/lib/x86_64-linux-gnu/pkgconfig",
                "/usr/lib/aarch64-linux-gnu/pkgconfig",
                "/usr/share/pkgconfig",
            ]
        )
    conf_args = [
        f"--prefix={prefix}",
        f"--with-system-libdir={sys_lib_dir}",
        f"--with-pkg-config-dir={pc_path}",
    ]
    make_build(conf_args=conf_args)
