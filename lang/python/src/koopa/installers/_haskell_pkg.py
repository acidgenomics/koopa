"""Generic Haskell package installer."""

from __future__ import annotations

from koopa.install import install_haskell_package
from koopa.installers._args import get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Haskell package."""
    kwargs = parse_passthrough(passthrough_args)
    deps = get_list(kwargs, "dependencies")
    extra = get_list(kwargs, "extra_packages")
    install_haskell_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        ghc_version=get_str(kwargs, "ghc_version", "9.4.7"),
        dependencies=deps or None,
        extra_packages=extra or None,
    )
