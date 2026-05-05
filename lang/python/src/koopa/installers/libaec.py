"""Install libaec."""

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libaec."""
    env = activate_app("pkg-config", build_only=True)
    download_extract_cd()
    cmake_build(prefix=prefix, env=env)
