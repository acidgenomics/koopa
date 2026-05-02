"""Install go."""

from __future__ import annotations

import os
import subprocess
import sys

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
    os.makedirs(prefix, exist_ok=True)
    subprocess.run(
        ["tar", "-xf", tarball, "-C", prefix, "--strip-components=1"],
        check=True,
    )
