"""Install bcl2fastq."""

from __future__ import annotations

import os
import platform
import subprocess
from glob import glob

from koopa.archive import extract
from koopa.build import activate_app
from koopa.file_ops import init_dir, rm
from koopa.system import cpu_count


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bcl2fastq."""
    machine = platform.machine()
    if machine in ("aarch64", "arm64"):
        msg = "ARM64 is not supported for bcl2fastq."
        raise RuntimeError(msg)
    if not os.path.isfile("/usr/include/zlib.h"):
        msg = "System zlib is required."
        raise RuntimeError(msg)
    build_deps = ["cmake", "make"]
    deps: list[str] = []
    if platform.system() != "Darwin":
        deps.append("bzip2")
    deps.extend(["icu4c", "xz", "zlib", "zstd"])
    env = activate_app(*build_deps, build_only=True)
    env = activate_app(*deps, env=env)
    subprocess_env = env.to_env_dict()
    jobs = cpu_count()
    arch = platform.machine()
    c_include_path = f"/usr/include/{arch}-linux-gnu"
    if not os.path.isdir(c_include_path):
        msg = f"C include path does not exist: {c_include_path}"
        raise RuntimeError(msg)
    libexec = os.path.join(prefix, "libexec")
    init_dir(libexec)
    s3_base = "s3://private.koopa.acidgenomics.com/installers"
    s3_url = f"{s3_base}/bcl2fastq/src/{version}.tar.zip"
    local_file = f"{version}.tar.zip"
    subprocess.run(
        [
            "aws",
            "--profile=acidgenomics",
            "s3",
            "cp",
            s3_url,
            local_file,
        ],
        check=True,
    )
    extract(local_file, "unzip")
    tar_files = glob("unzip/*.tar.gz")
    if not tar_files:
        msg = "No tar.gz found in unzip directory."
        raise RuntimeError(msg)
    extract(tar_files[0], "src")
    rm("unzip")
    os.chdir("src")
    os.makedirs("build", exist_ok=True)
    os.chdir("build")
    subprocess_env["BOOST_ROOT"] = os.path.join(libexec, "boost")
    subprocess_env["C_INCLUDE_PATH"] = c_include_path
    cmake_cmd = "cmake"
    for path_dir in subprocess_env.get("PATH", "").split(":"):
        candidate = os.path.join(path_dir, "cmake")
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            cmake_cmd = candidate
            break
    conf_args = [
        "--build-type=Release",
        f"--parallel={jobs}",
        f"--prefix={prefix}",
        "--verbose",
        f"--with-cmake={cmake_cmd}",
        "--without-unit-tests",
    ]
    subprocess.run(
        ["../src/configure", *conf_args],
        env=subprocess_env,
        check=False,
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
