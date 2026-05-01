"""Install flex."""

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
    """Install flex."""
    env = activate_app("bison", build_only=True)
    env = activate_app("gettext", "m4", env=env)
    url = f"https://github.com/westes/flex/releases/download/v{version}/flex-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-shared",
            f"--prefix={prefix}",
        ],
        env=env,
    )
