"""Install bash-completion."""

from __future__ import annotations

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bash-completion."""
    url = (
        f"https://github.com/scop/bash-completion/releases/download/"
        f"{version}/bash-completion-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(conf_args=[f"--prefix={prefix}"])
