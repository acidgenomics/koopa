"""Install byobu."""

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
    """Install byobu."""
    env = activate_app("gettext", "tmux", env=None)
    url = (
        f"https://launchpad.net/byobu/trunk/{version}/+download/"
        f"byobu_{version}.orig.tar.gz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[f"--prefix={prefix}"],
        env=env,
    )
