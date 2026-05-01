"""Install glib."""

from __future__ import annotations

from koopa.build import activate_app, meson_build
from koopa.installers._build_helper import download_extract_cd


def _major_minor_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}.{parts[1]}"


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
    mm = _major_minor_version(version)
    url = f"https://download.gnome.org/sources/glib/{mm}/glib-{version}.tar.xz"
    download_extract_cd(url)
    meson_build(prefix=prefix, env=env)
