"""Install libevent."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libevent."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("openssl", env=env)
    url = (
        f"https://github.com/libevent/libevent/releases/download/"
        f"release-{version}-stable/libevent-{version}-stable.tar.gz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-debug-mode",
            "--disable-dependency-tracking",
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
