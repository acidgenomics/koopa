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
    arch_id = "arm64" if machine in ("aarch64", "arm64") else "x64"
    if sys.platform == "darwin":
        platform = "osx"
        ext = "zip"
    else:
        platform = "linux"
        ext = "tar.gz"
    url = (
        f"https://cdn.oxfordnanoportal.com/software/analysis/"
        f"dorado-{version}-{platform}-{arch_id}.{ext}"
    )
    tarball = download(url)
    extract(tarball, prefix)
