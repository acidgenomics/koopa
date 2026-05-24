"""Install zip."""

import os
import subprocess

from koopa.build import locate
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install zip."""
    env = activate_app_deps()
    make = locate("make")
    download_extract_cd()
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        [make, f"--jobs={jobs}", "-f", "unix/Makefile", "generic"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            "-f",
            "unix/Makefile",
            "install",
            f"prefix={prefix}",
            f"MANDIR={prefix}/share/man/man1",
        ],
        env=subprocess_env,
        check=True,
    )
