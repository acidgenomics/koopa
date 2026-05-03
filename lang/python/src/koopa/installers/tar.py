"""Install tar."""

from __future__ import annotations

import sys

from koopa.build import activate_app, app_prefix
from koopa.install import install_gnu_app


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tar."""
    env = activate_app("make", build_only=True)
    env = activate_app("libiconv", env=env)
    env.apply()
    iconv_prefix = app_prefix("libiconv")
    conf_args = [
        f"--program-prefix=g",
        f"--with-libiconv-prefix={iconv_prefix}",
    ]
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        conf_args=conf_args,
    )
