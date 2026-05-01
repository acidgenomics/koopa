"""Install asdf."""

from __future__ import annotations

import os

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install asdf."""
    url = f"https://github.com/asdf-vm/asdf/archive/v{version}.tar.gz"
    tarball = download(url)
    libexec = os.path.join(prefix, "libexec")
    extract(tarball, libexec)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    ln(
        os.path.join(libexec, "bin", "asdf"),
        os.path.join(bin_dir, "asdf"),
    )
