"""Install gettext (runtime only)."""

import os

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gettext."""
    env = activate_app_deps()
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
