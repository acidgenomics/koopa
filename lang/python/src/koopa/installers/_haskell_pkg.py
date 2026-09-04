"""Generic Haskell package installer."""

from koopa.install import install_haskell_package
from koopa.installers._args import get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Haskell package.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
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
