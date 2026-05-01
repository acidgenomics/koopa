"""Generic Rust package installer."""

from __future__ import annotations

from koopa.install import install_rust_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Rust package."""
    kwargs = parse_passthrough(passthrough_args)
    install_rust_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        features=get_str(kwargs, "features"),
        git_url=get_str(kwargs, "git_url"),
        tag=get_str(kwargs, "tag"),
        with_openssl=get_str(kwargs, "with_openssl") == "true",
    )
