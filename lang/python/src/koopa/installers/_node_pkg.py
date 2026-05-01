"""Generic Node.js package installer."""

from __future__ import annotations

from koopa.install import install_node_package
from koopa.installers._args import get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Node.js package."""
    kwargs = parse_passthrough(passthrough_args)
    extra = get_list(kwargs, "extra_packages")
    install_node_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        extra_packages=extra or None,
    )
