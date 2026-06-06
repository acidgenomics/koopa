"""Install 1password-cli."""

import os
import stat
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import mkdir
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install 1password-cli."""
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    machine = arch2()
    platform = "darwin" if sys.platform == "darwin" else "linux"
    url = (
        f"https://cache.agilebits.com/dist/1P/op2/pkg/v{version}/"
        f"op_{platform}_{machine}_v{version}.zip"
    )
    zipfile = download(url)
    extract(zipfile, bin_dir)
    op_bin = os.path.join(bin_dir, "op")
    os.chmod(op_bin, os.stat(op_bin).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
