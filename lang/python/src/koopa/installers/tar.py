"""Install tar."""

from __future__ import annotations

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
    """Install tar."""
    env = activate_app("make", build_only=True)
    env = activate_app("libiconv", env=env)
    iconv_prefix = app_prefix("libiconv")
    iconv_lib = os.path.join(iconv_prefix, "lib")
    env.ldflags.append(f"-L{iconv_lib}")
    env.ldflags.append("-liconv")
    url = f"https://ftp.gnu.org/gnu/tar/tar-{version}.tar.gz"
    download_extract_cd(url)
    os.environ["FORCE_UNSAFE_CONFIGURE"] = "1"
    make_build(
        conf_args=[
            "--program-prefix=g",
            f"--prefix={prefix}",
            f"--with-libiconv-prefix={iconv_prefix}",
        ],
        env=env,
    )
