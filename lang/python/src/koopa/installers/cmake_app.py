"""Install cmake."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install cmake."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app("zlib", "zstd", "openssl", "libssh2", "curl", env=env)
    make = locate("make")
    url = f"https://github.com/Kitware/CMake/releases/download/v{version}/cmake-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    if sys.platform != "darwin":
        jobs = 1
    bootstrap_args = [
        f"--prefix={prefix}",
        f"--parallel={jobs}",
        "--system-curl",
        "--system-zlib",
        "--system-zstd",
        "--",
        "-DCMAKE_USE_OPENSSL=ON",
    ]
    subprocess.run(
        ["./bootstrap", *bootstrap_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, f"--jobs={jobs}", "VERBOSE=1"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
    cmake = os.path.join(prefix, "bin", "cmake")
    result = subprocess.run(
        [cmake, "--system-information"],
        capture_output=True,
        text=True,
    )
    assert "CMAKE_USE_OPENSSL" in result.stdout, "CMake lacks TLS support"
