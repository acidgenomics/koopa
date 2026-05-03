"""Install pkg-config."""

from __future__ import annotations

import os
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
    """Install pkg-config."""
    env = activate_app("make", build_only=True)
    url = f"https://pkgconfig.freedesktop.org/releases/pkg-config-{version}.tar.gz"
    download_extract_cd(url)
    if sys.platform == "darwin":
        sys_inc_dir = "/usr/include"
        pc_path = "/usr/lib/pkgconfig"
    else:
        sys_inc_dir = "/usr/include"
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
        f"--with-system-include-path={sys_inc_dir}",
        f"--with-pc-path={pc_path}",
        "--with-internal-glib",
        "--disable-host-tool",
    ]
    # Bundled GLib has integer-to-pointer conversion issues in gatomic.c
    # that newer Clang (Apple Command Line Tools) treats as errors.
    cflags = os.environ.get("CFLAGS", "")
    os.environ["CFLAGS"] = f"{cflags} -Wno-int-conversion".strip()
    make_build(conf_args=conf_args, env=env)
    pkg_config = os.path.join(prefix, "bin", "pkg-config")
    assert os.path.isfile(pkg_config), f"pkg-config not found at {pkg_config}"
