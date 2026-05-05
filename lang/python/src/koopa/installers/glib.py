"""Install glib."""

from koopa.build import activate_app, meson_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install glib."""
    env = activate_app("cmake", "meson", "ninja", "pkg-config", "python", build_only=True)
    env = activate_app("zlib", "libffi", "pcre2", env=env)
    download_extract_cd()
    meson_build(prefix=prefix, env=env)
