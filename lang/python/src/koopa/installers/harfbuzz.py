"""Install harfbuzz."""

from koopa.build import activate_app, meson_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install harfbuzz."""
    env = activate_app("cmake", "meson", "ninja", "pkg-config", build_only=True)
    env = activate_app(
        "zlib",
        "gettext",
        "libffi",
        "pcre2",
        "glib",
        "freetype",
        "icu4c",
        env=env,
    )
    download_extract_cd()
    meson_build(
        prefix=prefix,
        args=[
            "-Dcairo=disabled",
            "-Dcoretext=enabled",
            "-Dfreetype=enabled",
            "-Dglib=enabled",
            "-Dgobject=disabled",
            "-Dgraphite=disabled",
            "-Dicu=enabled",
            "-Dintrospection=disabled",
        ],
        env=env,
    )
