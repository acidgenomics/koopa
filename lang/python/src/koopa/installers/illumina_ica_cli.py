"""Install illumina-ica-cli."""

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
    """Install illumina-ica-cli.

    Illumina publishes amd64 archives only; this app is gated to linux-amd64
    in app.json.
    """
    url = (
        f"https://stratus-documentation-us-east-1-public.s3.amazonaws.com/"
        f"cli/{version}/ica-linux-amd64.zip"
    )
    zipfile = download(url)
    extract(zipfile, "src")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    icav2_bin = os.path.join("src", "icav2")
    if not os.path.isfile(icav2_bin):
        for entry in os.listdir("src"):
            candidate = os.path.join("src", entry)
            if os.path.isfile(candidate) and "icav2" in entry:
                icav2_bin = candidate
                break
    shutil.copy2(icav2_bin, os.path.join(bin_dir, "icav2"))
    os.chmod(os.path.join(bin_dir, "icav2"), 0o755)
