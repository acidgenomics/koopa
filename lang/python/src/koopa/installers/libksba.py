"""Install libksba."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libksba."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libgpg-error", env=env)
    lgpe_prefix = app_prefix("libgpg-error")
    gcrypt_url = "https://gnupg.org/ftp/gcrypt"
    url = f"{gcrypt_url}/libksba/libksba-{version}.tar.bz2"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            f"--prefix={prefix}",
            f"--with-libgpg-error-prefix={lgpe_prefix}",
        ],
        env=env,
    )
