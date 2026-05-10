"""Generic Perl package installer."""

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
    version_prefix = get_str(kwargs, "version_prefix")
    deps = get_list(kwargs, "dependencies")
    install_perl_package(
        cpan_path=cpan_path,
        version=version,
        prefix=prefix,
        version_prefix=version_prefix,
        dependencies=deps or None,
    )
