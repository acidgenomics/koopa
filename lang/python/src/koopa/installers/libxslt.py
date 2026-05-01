"""Install libxslt."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
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
    """Install libxslt."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app(
        "icu4c", "libxml2", "libgpg-error", "libgcrypt", env=env
    )
    libxml2_prefix = app_prefix("libxml2")
    mm = _major_minor_version(version)
    url = (
        f"https://download.gnome.org/sources/libxslt/"
        f"{mm}/libxslt-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--with-crypto",
            f"--with-libxml-prefix={libxml2_prefix}",
            "--without-python",
            f"--prefix={prefix}",
        ],
        env=env,
    )
