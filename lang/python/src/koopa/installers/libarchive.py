"""Install libarchive."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libarchive."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-static",
            "--without-lzma",
            "--without-lzo2",
            "--without-nettle",
            "--without-openssl",
            "--without-xml2",
            f"--prefix={prefix}",
        ],
        env=env,
    )
