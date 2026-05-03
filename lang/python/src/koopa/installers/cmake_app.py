"""Install cmake."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import _cmake_std_args, activate_app, app_prefix, locate
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
    env = activate_app("openssl", env=env)
    make = locate("make")
    url = f"https://github.com/Kitware/CMake/releases/download/v{version}/cmake-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    if sys.platform != "darwin":
        jobs = 1
    openssl_root = app_prefix("openssl")
    cmake_args = _cmake_std_args(
        prefix=prefix,
        generator="Unix Makefiles",
        subprocess_env=subprocess_env,
    )
    cmake_args += [
        "-DCMake_BUILD_LTO=ON",
        f"-DOPENSSL_ROOT_DIR={openssl_root}",
        "-DCMAKE_USE_OPENSSL=ON",
    ]
    bootstrap_args = [
        "--no-system-libs",
        f"--prefix={prefix}",
        f"--parallel={jobs}",
        "--",
        *cmake_args,
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
        check=False,
    )
    assert "CMAKE_USE_OPENSSL" in result.stdout, "CMake lacks TLS support"
