"""Generic Perl package installer."""

from __future__ import annotations

from koopa.install import install_perl_package
from koopa.installers._args import get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Perl package."""
    kwargs = parse_passthrough(passthrough_args)
    cpan_path = get_str(kwargs, "cpan_path")
    if not cpan_path:
        msg = f"Perl package '{name}' requires a --cpan-path passthrough arg."
        raise ValueError(msg)
    deps = get_list(kwargs, "dependencies")
    install_perl_package(
        cpan_path=cpan_path,
        version=version,
        prefix=prefix,
        dependencies=deps or None,
    )
