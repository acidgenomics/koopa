"""Install msgpack."""

import os

from koopa.build import activate_app, app_prefix, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install msgpack."""
    env = activate_app("boost", env=None)
    boost_prefix = app_prefix("boost")
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=[f"-DBoost_INCLUDE_DIR={os.path.join(boost_prefix, 'include')}"],
        env=env,
    )
