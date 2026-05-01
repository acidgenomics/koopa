"""Install walk."""

from __future__ import annotations

from koopa.install import install_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install walk."""
    url = f"github.com/antonmedv/walk@v{version}"
    install_go_package(url=url, prefix=prefix)
