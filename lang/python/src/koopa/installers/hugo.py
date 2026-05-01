"""Install hugo."""

from __future__ import annotations

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install hugo."""
    url = f"https://github.com/gohugoio/hugo/archive/v{version}.tar.gz"
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        ldflags="-s -w",
        tags="extended",
    )
