"""Generic Rust package installer."""

from koopa.install import install_rust_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Rust package.

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
    install_rust_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        features=get_str(kwargs, "features"),
        git_url=get_str(kwargs, "git_url"),
        tag=get_str(kwargs, "tag"),
        with_openssl=get_str(kwargs, "with_openssl") == "true",
        rustflags=get_str(kwargs, "rustflags"),
    )
