"""Install pup."""

from __future__ import annotations

from koopa.install import install_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pup."""
    url = f"github.com/ericchiang/pup@v{version}"
    install_go_package(url=url, prefix=prefix)
