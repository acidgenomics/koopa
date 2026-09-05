"""Install yq."""

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install yq.

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
    url = f"https://github.com/mikefarah/yq/archive/v{version}.tar.gz"
    build_go_package(url=url, name=name, version=version, prefix=prefix)
