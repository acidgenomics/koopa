"""Install s5cmd."""

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install s5cmd.

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
    url = f"https://github.com/peak/s5cmd/archive/refs/tags/v{version}.tar.gz"
    ldflags = f"-s -w -X=github.com/peak/s5cmd/v2/version.Version={version}"
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        ldflags=ldflags,
    )
