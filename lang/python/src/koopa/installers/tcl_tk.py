"""Install tcl-tk."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate
from koopa.download import download
from koopa.archive import extract
from koopa.file_ops import ln
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tcl-tk."""
    env = activate_app("make", "pkg-config", build_only=True)
    if sys.platform != "darwin":
        env = activate_app(
            "xorg-xorgproto", "xorg-xcb-proto", "xorg-libpthread-stubs",
            "xorg-libxau", "xorg-libxdmcp", "xorg-libxcb",
            "xorg-libx11", "xorg-libxext", "xorg-libxrender",
            env=env,
        )
    make = locate("make")
    maj_min_ver = major_minor_version(version)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    tcl_url = (
        f"https://koopa.acidgenomics.com/src/tcl/tcl{version}-src.tar.gz"
    )
    tk_url = (
        f"https://koopa.acidgenomics.com/src/tk/tk{version}-src.tar.gz"
    )
    tcl_tarball = download(tcl_url)
    tk_tarball = download(tk_url)
    extract(tcl_tarball, "tcl-src")
    extract(tk_tarball, "tk-src")
    tcl_unix = os.path.join("tcl-src", "unix")
    tk_unix = os.path.join("tk-src", "unix")
    os.chdir(tcl_unix)
    tcl_conf_args = [
        f"--prefix={prefix}",
        "--enable-threads",
    ]
    subprocess.run(
        ["./configure", *tcl_conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
    os.chdir(os.path.join("..", "..", tk_unix))
    tk_conf_args = [
        f"--prefix={prefix}",
        "--enable-threads",
        f"--with-tcl={prefix}/lib",
    ]
    subprocess.run(
        ["./configure", *tk_conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
    bin_dir = os.path.join(prefix, "bin")
    ln(f"tclsh{maj_min_ver}", os.path.join(bin_dir, "tclsh"))
    ln(f"wish{maj_min_ver}", os.path.join(bin_dir, "wish"))
