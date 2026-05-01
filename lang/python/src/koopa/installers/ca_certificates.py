"""Install ca-certificates."""

from __future__ import annotations

import os
import shutil

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ca-certificates."""
    filename = f"cacert-{version}.pem"
    url = f"https://curl.se/ca/{filename}"
    tarball = download(url)
    dest_dir = os.path.join(prefix, "share", "ca-certificates")
    os.makedirs(dest_dir, exist_ok=True)
    shutil.copy2(tarball, os.path.join(dest_dir, "cacert.pem"))
