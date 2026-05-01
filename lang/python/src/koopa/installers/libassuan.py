"""Install libassuan."""

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
    """Install libassuan."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libgpg-error", env=env)
    lgpe_prefix = app_prefix("libgpg-error")
    gcrypt_url = "https://gnupg.org/ftp/gcrypt"
    url = f"{gcrypt_url}/libassuan/libassuan-{version}.tar.bz2"
    download_extract_cd(url)
    cflags = os.environ.get("CFLAGS", "")
    cflags = f"-std=gnu89 {cflags}".strip()
    env.cppflags.insert(0, "-std=gnu89")
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            f"--prefix={prefix}",
            f"--with-libgpg-error-prefix={lgpe_prefix}",
        ],
        env=env,
    )
