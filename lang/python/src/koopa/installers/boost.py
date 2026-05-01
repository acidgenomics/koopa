"""Install boost."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, app_prefix
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install boost."""
    deps = []
    if sys.platform != "darwin":
        deps.append("bzip2")
    deps.extend(["icu4c", "xz", "zlib", "zstd"])
    env = activate_app(*deps)
    icu4c_prefix = app_prefix("icu4c")
    subprocess_env = env.to_env_dict()
    cc = os.environ.get("CC", "gcc")
    toolset = os.path.basename(cc)
    url = (
        f"https://github.com/boostorg/boost/releases/download/"
        f"boost-{version}/boost-{version}-b2-nodocs.tar.gz"
    )
    download_extract_cd(url)
    jobs = os.cpu_count() or 1
    bootstrap_args = [
        f"--libdir={prefix}/lib",
        f"--prefix={prefix}",
        f"--with-icu={icu4c_prefix}",
        f"--with-toolset={toolset}",
        "--without-libraries=log,mpi,python",
    ]
    cppflags = subprocess_env.get("CPPFLAGS", "")
    ldflags = subprocess_env.get("LDFLAGS", "")
    b2_args = [
        "-q",
        "-d+2",
        f"-j{jobs}",
        f"--libdir={prefix}/lib",
        f"--prefix={prefix}",
        f"cxxflags={cppflags}",
        "link=shared",
        f"linkflags={ldflags}",
        "runtime-link=shared",
        f"toolset={toolset}",
        "threading=multi",
        "variant=release",
        "install",
    ]
    subprocess.run(
        ["./bootstrap.sh", *bootstrap_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["./b2", *b2_args],
        env=subprocess_env,
        check=True,
    )
