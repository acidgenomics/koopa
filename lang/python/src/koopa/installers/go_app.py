"""Install go."""

from __future__ import annotations

import os
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install go."""
    arch = arch2()
    os_id = "darwin" if sys.platform == "darwin" else "linux"
    url = f"https://dl.google.com/go/go{version}.{os_id}-{arch}.tar.gz"
    tarball = download(url)
    extract(tarball, prefix)
