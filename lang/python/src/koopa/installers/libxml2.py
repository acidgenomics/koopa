"""Install libxml2."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libxml2."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--enable-static=no",
            "--with-ftp",
            "--with-history",
            "--with-iconv",
            "--with-icu",
            "--with-legacy",
            "--with-lzma",
            "--with-readline",
            "--with-tls",
            "--with-zlib",
            "--without-python",
            f"--prefix={prefix}",
        ],
        env=env,
    )
