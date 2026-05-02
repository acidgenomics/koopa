"""Install powershell."""

from __future__ import annotations

import os
import stat
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import ln, mkdir
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install powershell."""
    machine = arch2()
    if sys.platform == "darwin":
        platform_id = f"osx-{machine}"
    elif sys.platform == "linux":
        platform_id = f"linux-{machine}"
    else:
        msg = f"Unsupported platform: {sys.platform}"
        raise RuntimeError(msg)
    url = (
        f"https://github.com/PowerShell/PowerShell/releases/download/"
        f"v{version}/powershell-{version}-{platform_id}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, prefix)
    pwsh = os.path.join(prefix, "pwsh")
    os.chmod(pwsh, os.stat(pwsh).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    ln(pwsh, os.path.join(bin_dir, "pwsh"))
