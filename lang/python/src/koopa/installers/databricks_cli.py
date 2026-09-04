"""Install databricks-cli."""

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install databricks-cli.

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
    url = f"https://github.com/databricks/cli/archive/v{version}.tar.gz"
    ldflags = f"-X github.com/databricks/cli/internal/build.buildVersion={version}"
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        bin_name="databricks",
        ldflags=ldflags,
    )
