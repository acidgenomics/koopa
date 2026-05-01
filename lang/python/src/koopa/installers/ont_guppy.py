"""Install ont-guppy."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.archive import extract
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ont-guppy."""
    machine = arch()
    if sys.platform == "darwin":
        platform = "macos"
    else:
        platform = "linux"
    arch_id = "amd64" if machine in ("x86_64",) else machine
    core = "cpu"
    s3_url = (
        f"s3://acidgenomics/installers/ont-guppy/"
        f"ont-guppy-{version}-{platform}-{arch_id}-{core}.tar.gz"
    )
    subprocess.run(
        [
            "aws",
            "--profile=acidgenomics",
            "s3",
            "cp",
            s3_url,
            ".",
        ],
        check=True,
    )
    tarball = os.path.basename(s3_url)
    extract(tarball, prefix)
