"""Install r-gfortran."""

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
    """Install r-gfortran."""
    url = f"https://mac.r-project.org/tools/gfortran-{version}-universal.pkg"
    pkg_file = download(url)
    subprocess.run(
        ["sudo", "installer", "-pkg", pkg_file, "-target", "/"],
        check=True,
    )
