"""Install pixman."""

from koopa.build import activate_app, meson_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pixman."""
    env = activate_app("meson", "ninja", "pkg-config", build_only=True)
    download_extract_cd()
    meson_build(prefix=prefix, env=env)
