"""Install diff-so-fancy."""

import os
import shutil

from koopa.file_ops import ln
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install diff-so-fancy."""
    download_extract_cd()
    bin_dir = os.path.join(prefix, "bin")
    libexec_dir = os.path.join(prefix, "libexec")
    os.makedirs(bin_dir, exist_ok=True)
    os.makedirs(libexec_dir, exist_ok=True)
    shutil.copy2("diff-so-fancy", libexec_dir)
    if os.path.isdir("lib"):
        shutil.copytree("lib", os.path.join(libexec_dir, "lib"))
    ln(
        os.path.join("..", "libexec", "diff-so-fancy"),
        os.path.join(bin_dir, "diff-so-fancy"),
    )
