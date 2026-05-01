"""Install s5cmd."""

from __future__ import annotations

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install s5cmd."""
    url = (
        f"https://github.com/peak/s5cmd/archive/refs/tags/v{version}.tar.gz"
    )
    ldflags = (
        f"-s -w -X=github.com/peak/s5cmd/v2/version.Version={version}"
    )
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        ldflags=ldflags,
    )
