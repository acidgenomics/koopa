"""Install libtool."""

from __future__ import annotations

import os

from koopa.build import activate_app
from koopa.file_ops import ln
from koopa.install import install_gnu_app


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libtool."""
    env = activate_app("make", build_only=True)
    env = activate_app("m4", env=env)
    env.apply()
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        conf_args=["--disable-static"],
    )
    bin_dir = os.path.join(prefix, "bin")
    ln("libtool", os.path.join(bin_dir, "glibtool"))
    ln("libtoolize", os.path.join(bin_dir, "glibtoolize"))
