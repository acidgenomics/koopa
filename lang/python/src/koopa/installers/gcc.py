"""Install GCC."""

import os
import subprocess

from koopa.archive import extract
from koopa.build import activate_app, app_prefix
from koopa.download import download_with_mirror
from koopa.installers._build_helper import _resolve_src_url
from koopa.system import cpu_count


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install GCC."""
    env = activate_app("make", build_only=True)
    gmp_prefix = app_prefix("gmp")
    isl_prefix = app_prefix("isl")
    mpc_prefix = app_prefix("mpc")
    mpfr_prefix = app_prefix("mpfr")
    zstd_prefix = app_prefix("zstd")
    langs = "c,c++,fortran,objc,obj-c++"
    conf_args = [
        "-v",
        "--disable-multilib",
        "--disable-nls",
        "--enable-checking=release",
        "--enable-default-pie",
        f"--enable-languages={langs}",
        f"--prefix={prefix}",
        f"--with-gmp={gmp_prefix}",
        f"--with-isl={isl_prefix}",
        f"--with-mpc={mpc_prefix}",
        f"--with-mpfr={mpfr_prefix}",
        "--with-system-zlib",
        f"--with-zstd={zstd_prefix}",
    ]
    url = _resolve_src_url(name, version)
    filename = os.path.basename(url)
    tarball = download_with_mirror(url, name, filename)
    extract(tarball, "src")
    os.makedirs("build", exist_ok=True)
    os.chdir("build")
    subprocess_env = env.to_env_dict()
    jobs = cpu_count()
    subprocess.run(
        ["../src/configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["make", f"-j{jobs}", "VERBOSE=1"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["make", "install"],
        env=subprocess_env,
        check=True,
    )
