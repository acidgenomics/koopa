"""Install illumina-ica-cli."""

from __future__ import annotations

import os
import shutil
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
    """Install illumina-ica-cli."""
    if sys.platform == "darwin":
        os_id = "darwin"
    else:
        os_id = "linux"
    machine = arch()
    url = (
        f"https://stratus-documentation-us-east-1-public.s3.amazonaws.com/"
        f"cli/{version}/{os_id}/{machine}/icav2"
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    download(url, output=os.path.join(bin_dir, "icav2"))
    os.chmod(os.path.join(bin_dir, "icav2"), 0o755)
