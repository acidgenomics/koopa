"""Install libxcrypt."""

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
    """Install libxcrypt."""
    env = activate_app("perl", "pkg-config", build_only=True)
    url = (
        f"https://github.com/besser82/libxcrypt/releases/download/"
        f"v{version}/libxcrypt-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-failure-tokens",
            "--disable-static",
            "--enable-hashes=strong",
            f"--prefix={prefix}",
        ],
        env=env,
    )
