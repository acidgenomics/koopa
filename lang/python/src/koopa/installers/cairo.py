"""Install cairo."""

import sys

from koopa.build import meson_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install cairo."""
    env = activate_app_deps()
    download_extract_cd()
    meson_args = [
        "-Dfontconfig=enabled",
        "-Dfreetype=enabled",
        "-Dglib=enabled",
        "-Dpng=enabled",
        "-Dzlib=enabled",
    ]
    if sys.platform == "darwin":
        meson_args.append("-Dquartz=disabled")
    else:
        meson_args.extend(
            [
                "-Dxcb=enabled",
                "-Dxlib-xcb=enabled",
                "-Dxlib=enabled",
            ]
        )
    meson_build(prefix=prefix, args=meson_args, env=env)
