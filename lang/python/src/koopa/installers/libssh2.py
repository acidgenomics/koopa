"""Install libssh2."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libssh2."""
    env = activate_app_deps()
    openssl_prefix = app_prefix("openssl")
    zlib_prefix = app_prefix("zlib")
    download_extract_cd()
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
