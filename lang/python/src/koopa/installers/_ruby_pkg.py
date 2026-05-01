"""Generic Ruby package installer."""

from __future__ import annotations

from koopa.install import install_ruby_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Ruby package."""
    kwargs = parse_passthrough(passthrough_args)
    install_ruby_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
    )
