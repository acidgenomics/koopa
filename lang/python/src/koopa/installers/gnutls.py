"""Install gnutls."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gnutls."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("gmp", "libtasn1", "libunistring", "nettle", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-full-test-suite",
            "--disable-guile",
            "--disable-heartbeat-support",
            "--disable-libdane",
            "--disable-maintainer-mode",
            "--disable-static",
            "--enable-openssl-compatibility",
            "--with-idn",
            "--with-included-unistring",
            "--without-brotli",
            "--without-p11-kit",
            "--without-zlib",
            "--without-zstd",
            f"--prefix={prefix}",
        ],
        env=env,
    )
