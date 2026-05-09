"""Install shunit2."""

import os
import shutil

from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install shunit2."""
    download_extract_cd()
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    shutil.copy2("shunit2", os.path.join(bin_dir, "shunit2"))
