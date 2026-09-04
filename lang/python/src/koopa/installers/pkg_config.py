"""Install pkg-config."""

import os
import sys

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pkg-config.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    env = activate_app_deps()
    download_extract_cd()
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
