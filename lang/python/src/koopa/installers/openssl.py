"""Install openssl."""

import os
import platform
import subprocess
import sys

from koopa.build import app_prefix, locate
from koopa.file_ops import ln
from koopa.installers._build_helper import activate_app_deps, download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install openssl."""
    env = activate_app_deps()
    ca_prefix = app_prefix("ca-certificates")
    ca_bundle = os.path.join(ca_prefix, "share", "ca-certificates", "cacert.pem")
    make = locate("make")
    download_extract_cd()
    subprocess_env = env.to_env_dict()
    machine = platform.machine()
    if sys.platform == "darwin":
        arch_args = [f"darwin64-{machine}-cc", "enable-ec_nistp_64_gcc_128"]
    elif machine in ("x86_64", "amd64"):
        arch_args = ["linux-x86_64", "enable-ec_nistp_64_gcc_128"]
    elif machine in ("aarch64", "arm64"):
        arch_args = ["linux-aarch64"]
    else:
        arch_args = []
    conf_args = [
        "--libdir=lib",
        f"--openssldir={prefix}",
        f"--prefix={prefix}",
        f"-Wl,-rpath,{prefix}/lib",
        "-fPIC",
        "no-ssl3",
        "no-ssl3-method",
        "no-zlib",
        "shared",
    ]
    if sys.platform != "darwin":
        conf_args.append("-Wl,--enable-new-dtags")
    subprocess.run(
        ["./Configure", *arch_args, *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "--jobs=1", "depend"],
        env=subprocess_env,
        check=True,
    )
    jobs = os.cpu_count() or 1
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
    remove_static_libs(prefix)
    certs_dir = os.path.join(prefix, "certs")
    os.makedirs(certs_dir, exist_ok=True)
    ln(ca_bundle, os.path.join(certs_dir, "cacert.pem"))
