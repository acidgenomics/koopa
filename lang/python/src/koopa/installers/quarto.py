"""Install quarto."""

from __future__ import annotations

import sys

from koopa.archive import extract
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install quarto."""
    if sys.platform == "darwin":
        slug = "macos"
    else:
        slug = "linux-amd64"
    url = (
        f"https://github.com/quarto-dev/quarto-cli/releases/download/"
        f"v{version}/quarto-{version}-{slug}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, prefix)
