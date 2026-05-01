"""Install air."""

from __future__ import annotations

from koopa.install import install_rust_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install air."""
    install_rust_package(
        name=name,
        version=version,
        prefix=prefix,
        git_url="https://github.com/posit-dev/air",
        tag=version,
    )
