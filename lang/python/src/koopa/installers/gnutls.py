"""Install gnutls."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def _major_minor_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}.{parts[1]}"


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
    mm = _major_minor_version(version)
    gcrypt_url = "https://gnupg.org/ftp/gcrypt"
    url = f"{gcrypt_url}/gnutls/v{mm}/gnutls-{version}.tar.xz"
    download_extract_cd(url)
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
