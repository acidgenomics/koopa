"""Install libssh2."""

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
    """Install libssh2."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "openssl", env=env)
    openssl_prefix = app_prefix("openssl")
    zlib_prefix = app_prefix("zlib")
    url = f"https://www.libssh2.org/download/libssh2-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-examples-build",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
            "--with-crypto=openssl",
            f"--with-libssl-prefix={openssl_prefix}",
            f"--with-libz-prefix={zlib_prefix}",
        ],
        env=env,
    )
