"""Install zlib."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install zlib."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
    remove_static_libs(prefix)
