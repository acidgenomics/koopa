"""Install libedit."""

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
    """Install libedit."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("ncurses", env=env)
    url = f"https://thrysoee.dk/editline/libedit-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
