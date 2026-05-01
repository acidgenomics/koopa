"""Install jfrog-cli."""

from __future__ import annotations

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install jfrog-cli."""
    url = (
        f"https://github.com/jfrog/jfrog-cli/archive/refs/tags/"
        f"v{version}.tar.gz"
    )
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        bin_name="jf",
        ldflags="-s -w",
    )
