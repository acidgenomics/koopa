"""Install air."""

from koopa.install import install_rust_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install air.

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
    install_rust_package(
        name=name,
        version=version,
        prefix=prefix,
        git_url="https://github.com/posit-dev/air",
        tag=version,
    )
