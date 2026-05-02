"""Install elvish."""

from __future__ import annotations

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install elvish."""
    url = f"https://github.com/elves/elvish/archive/refs/tags/v{version}.tar.gz"
    build_go_package(url=url, prefix=prefix, name=name, version=version)
