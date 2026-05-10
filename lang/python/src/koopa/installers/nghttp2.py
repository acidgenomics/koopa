"""Install nghttp2."""

from koopa.build import activate_app, locate, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nghttp2."""
    env = activate_app("pkg-config", "python", build_only=True)
    env = activate_app(
        "c-ares",
        "icu4c",
        "libxml2",
        "openssl",
        "zlib",
        env=env,
    )
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
