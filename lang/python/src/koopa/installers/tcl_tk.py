"""Install tcl-tk."""

import os
import subprocess
import sys

from koopa.archive import extract
from koopa.build import locate
from koopa.download import download_with_mirror
from koopa.file_ops import ln
from koopa.installers._build_helper import activate_app_deps, _resolve_extra_src_urls, _resolve_src_url
from koopa.version import major_minor_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tcl-tk."""
    env = activate_app_deps()
    make = locate("make")
    maj_min_ver = major_minor_version(version)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    tcl_url = _resolve_src_url(name, version)
    tcl_tarball = download_with_mirror(tcl_url, name, f"tcl{version}-src.tar.gz")
    extra_urls = _resolve_extra_src_urls(name, version)
    tk_url = extra_urls[0]
    tk_tarball = download_with_mirror(tk_url, name, f"tk{version}-src.tar.gz")
    extract(tcl_tarball, "tcl-src")
    extract(tk_tarball, "tk-src")
    tcl_unix = os.path.join("tcl-src", "unix")
    tk_unix = os.path.join("tk-src", "unix")
    os.chdir(tcl_unix)
    tcl_conf_args = [
        f"--prefix={prefix}",
        "--enable-shared",
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
    if sys.platform == "darwin":
        tk_conf_args.append("--enable-aqua=yes")
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
