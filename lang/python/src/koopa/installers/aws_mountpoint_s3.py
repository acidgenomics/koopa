"""Install aws-mountpoint-s3."""

from __future__ import annotations

import os
import subprocess

from koopa.download import download
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install aws-mountpoint-s3."""
    machine = arch()
    if machine == "aarch64":
        machine = "arm64"
    url = (
        f"https://s3.amazonaws.com/mountpoint-s3-release/{version}/"
        f"{machine}/mount-s3-{version}-{machine}.deb"
    )
    deb_file = download(url)
    subprocess.run(["sudo", "dpkg", "-i", deb_file], check=True)
    os.unlink(deb_file)
