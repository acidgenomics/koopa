"""Install ghostscript."""

import os
import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ghostscript."""
    env = activate_app("make", "pkg-config", build_only=True)
    make = locate("make")
    download_extract_cd()
    conf_args = [
        f"--prefix={prefix}",
        "--disable-gtk",
        "--disable-cups",
        "--without-tesseract",
        "--with-system-libtiff",
    ]
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        ["./configure", *conf_args],
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
    subprocess.run(
        [make, f"--jobs={jobs}", "so"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install-so"],
        env=subprocess_env,
        check=True,
    )
