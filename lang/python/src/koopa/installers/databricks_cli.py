"""Install databricks-cli."""

from __future__ import annotations

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install databricks-cli."""
    url = f"https://github.com/databricks/cli/archive/v{version}.tar.gz"
    ldflags = (
        f"-X github.com/databricks/cli/internal/build.buildVersion={version}"
    )
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        bin_name="databricks",
        ldflags=ldflags,
    )
