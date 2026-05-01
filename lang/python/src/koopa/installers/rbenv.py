"""Install rbenv."""

from __future__ import annotations

import os

from koopa.archive import extract
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install rbenv."""
    url = f"https://github.com/rbenv/rbenv/archive/v{version}.tar.gz"
    tarball = download(url)
    extract(tarball, prefix)
    plugins_dir = os.path.join(prefix, "plugins")
    os.makedirs(plugins_dir, exist_ok=True)
    rb_url = (
        "https://github.com/rbenv/ruby-build/archive/"
        "v20220713.tar.gz"
    )
    rb_tarball = download(rb_url)
    extract(rb_tarball, os.path.join(plugins_dir, "ruby-build"))
