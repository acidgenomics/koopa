"""Install axel."""

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
    """Install axel."""
    env = activate_app("gawk", "pkg-config", build_only=True)
    env = activate_app("gettext", "openssl", env=env)
    url = (
        f"https://github.com/axel-download-accelerator/axel/releases/download/"
        f"v{version}/axel-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-silent-rules",
            f"--prefix={prefix}",
        ],
        env=env,
    )
