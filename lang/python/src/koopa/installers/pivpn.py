"""Install pivpn."""

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
    """Install pivpn."""
    url = "https://install.pivpn.io"
    script = download(url)
    subprocess.run(["sudo", "bash", script], check=True)
