"""Install yq."""

from __future__ import annotations

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install yq."""
    url = f"https://github.com/mikefarah/yq/archive/v{version}.tar.gz"
    build_go_package(url=url, name=name, version=version, prefix=prefix)
