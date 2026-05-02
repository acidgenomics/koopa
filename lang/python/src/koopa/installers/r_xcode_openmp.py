"""Install r-xcode-openmp."""

from __future__ import annotations

import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r-xcode-openmp."""
    url = f"https://mac.r-project.org/openmp/openmp-{version}-darwin20-Release.tar.gz"
    tar_file = download(url)
    subprocess.run(
        ["sudo", "tar", "fxz", tar_file, "-C", "/"],
        check=True,
    )
