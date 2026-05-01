"""Install icu4c."""

from __future__ import annotations

import os

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install icu4c."""
    env = activate_app("pkg-config", build_only=True)
    kebab = version.replace(".", "-")
    snake = version.replace(".", "_")
    url = (
        f"https://github.com/unicode-org/icu/releases/download/"
        f"release-{kebab}/icu4c-{snake}-src.tgz"
    )
    download_extract_cd(url)
    os.chdir(os.path.join("icu", "source"))
    make_build(
        conf_args=[
            "--disable-samples",
            "--disable-static",
            "--disable-tests",
            "--enable-rpath",
            "--enable-shared",
            "--with-library-bits=64",
            f"--prefix={prefix}",
        ],
        env=env,
    )
