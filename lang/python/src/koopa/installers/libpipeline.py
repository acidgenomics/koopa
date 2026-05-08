"""Install libpipeline."""

from koopa.install import install_gnu_app


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libpipeline."""
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        non_gnu_mirror=True,
        extra_urls=[
            f"https://gitlab.com/libpipeline/libpipeline/-/archive/{version}/libpipeline-{version}.tar.gz",
            f"https://gitlab.com/api/v4/projects/libpipeline%2Flibpipeline/repository/archive.tar.gz?sha={version}",
        ],
    )
