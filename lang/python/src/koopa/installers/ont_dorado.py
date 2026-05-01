"""Install ont-dorado."""

from __future__ import annotations

import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ont-dorado."""
    machine = arch()
    if sys.platform == "darwin":
        platform = "osx"
        if machine in ("aarch64", "arm64"):
            arch_id = "arm64"
        else:
            arch_id = "x64"
        ext = "zip"
    else:
        platform = "linux"
        if machine in ("aarch64", "arm64"):
            arch_id = "arm64"
        else:
            arch_id = "x64"
        ext = "tar.gz"
    url = (
        f"https://cdn.oxfordnanoportal.com/software/analysis/"
        f"dorado-{version}-{platform}-{arch_id}.{ext}"
    )
    tarball = download(url)
    extract(tarball, prefix)
