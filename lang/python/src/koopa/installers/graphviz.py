"""Install graphviz."""

from __future__ import annotations

import os

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install graphviz."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("expat", env=env)
    os.makedirs(os.path.join(prefix, "lib"), exist_ok=True)
    url = (
        f"https://gitlab.com/api/v4/projects/4207231/"
        f"packages/generic/graphviz-releases/{version}/"
        f"graphviz-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-debug",
            "--disable-man-pdfs",
            "--disable-static",
            "--enable-shared",
            f"--prefix={prefix}",
        ],
        env=env,
    )
