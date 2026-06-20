"""Install gnutls."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gnutls."""
    env = activate_app_deps()
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
