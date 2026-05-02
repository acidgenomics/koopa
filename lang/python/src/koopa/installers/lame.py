"""Install lame."""

from __future__ import annotations

import re

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install lame."""
    url = f"https://sourceforge.net/projects/lame/files/lame/{version}/lame-{version}.tar.gz/download"
    download_extract_cd(url)
    sym_file = "include/libmp3lame.sym"
    with open(sym_file) as fh:
        text = fh.read()
    text = re.sub(r"^\s*lame_init_old\s*\n?", "", text, flags=re.MULTILINE)
    with open(sym_file, "w") as fh:
        fh.write(text)
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            "--enable-nasm",
        ],
    )
