"""Install gettext (runtime only)."""

import os

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gettext."""
    env = activate_app("make", "xz", build_only=True)
    env = activate_app("libiconv", "libunistring", "ncurses", env=env)
    libiconv_prefix = app_prefix("libiconv")
    download_extract_cd()
    os.chdir("gettext-runtime")
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            "--disable-csharp",
            "--disable-java",
            "--disable-libasprintf",
            "--disable-openmp",
            "--disable-static",
            f"--with-libiconv-prefix={libiconv_prefix}",
        ],
        env=env,
    )
