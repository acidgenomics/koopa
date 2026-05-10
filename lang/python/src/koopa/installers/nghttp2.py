"""Install nghttp2."""

from koopa.build import locate, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nghttp2."""
    env = activate_app_deps()
    python = locate("python3")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-examples",
            "--disable-hpack-tools",
            "--disable-silent-rules",
            "--disable-static",
            "--with-libcares",
            "--with-libxml2",
            "--with-openssl",
            "--with-zlib",
            "--without-systemd",
            f"PYTHON={python}",
            f"--prefix={prefix}",
        ],
        env=env,
    )
