"""Install xz."""

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
    """Install xz."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://github.com/tukaani-project/xz/releases/download/v{version}/xz-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-debug",
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
