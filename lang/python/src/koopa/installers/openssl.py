"""Install openssl."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, app_prefix, locate
from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install openssl."""
    env = activate_app("make", "pkg-config", "perl", build_only=True)
    env = activate_app("ca-certificates", env=env)
    ca_prefix = app_prefix("ca-certificates")
    ca_bundle = os.path.join(
        ca_prefix, "share", "ca-certificates", "cacert.pem"
    )
    make = locate("make")
    url = (
        f"https://github.com/openssl/openssl/releases/download/"
        f"openssl-{version}/openssl-{version}.tar.gz"
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    conf_args = [
        f"--libdir=lib",
        f"--openssldir={prefix}",
        f"--prefix={prefix}",
        f"-Wl,-rpath,{prefix}/lib",
        "-fPIC",
        "no-zlib",
        "shared",
    ]
    if sys.platform != "darwin":
        conf_args.append("-Wl,--enable-new-dtags")
    subprocess.run(
        ["./config", *conf_args],
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
