"""Install pihole."""

from __future__ import annotations

import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pihole."""
    url = "https://install.pi-hole.net"
    script = download(url)
    subprocess.run(["sudo", "bash", script], check=True)
