"""Install zlib."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install zlib."""
    env = activate_app("pkg-config", build_only=True)
    download_extract_cd()
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
    remove_static_libs(prefix)
