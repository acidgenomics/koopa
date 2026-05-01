"""Install shunit2."""

from __future__ import annotations

import os
import shutil

from koopa.archive import extract
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install shunit2."""
    url = f"https://github.com/kward/shunit2/archive/v{version}.tar.gz"
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    shutil.copy2("shunit2", os.path.join(bin_dir, "shunit2"))
