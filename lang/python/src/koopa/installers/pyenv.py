"""Install pyenv."""

from __future__ import annotations

import os

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pyenv."""
    url = f"https://github.com/pyenv/pyenv/archive/v{version}.tar.gz"
    tarball = download(url)
    extract(tarball, prefix)
    plugins_dir = os.path.join(prefix, "plugins")
    os.makedirs(plugins_dir, exist_ok=True)
    for plugin_name, plugin_ver, plugin_repo in [
        ("pyenv-multiuser", "1.0.8", "pyenv-multiuser"),
        ("pyenv-virtualenv", "1.2.4", "pyenv-virtualenv"),
    ]:
        purl = (
            f"https://github.com/pyenv/{plugin_repo}/archive/"
            f"v{plugin_ver}.tar.gz"
        )
        ptarball = download(purl)
        extract(ptarball, os.path.join(plugins_dir, plugin_name))
    for d in ("shims", "versions"):
        os.makedirs(os.path.join(prefix, d), mode=0o777, exist_ok=True)
