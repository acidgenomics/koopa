"""Install pixman."""

from koopa.build import meson_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pixman."""
    env = activate_app_deps()
    download_extract_cd()
    meson_build(prefix=prefix, env=env)
