"""Install TeX packages."""

from __future__ import annotations

import shutil
import subprocess
import sys

from koopa.build import activate_app

_PACKAGES = [
    "collection-fontsrecommended",
    "collection-latexrecommended",
    "bera",
    "biblatex",
    "caption",
    "changepage",
    "csvsimple",
    "enumitem",
    "etoolbox",
    "fancyhdr",
    "footmisc",
    "framed",
    "geometry",
    "hyperref",
    "inconsolata",
    "logreq",
    "marginfix",
    "mathtools",
    "natbib",
    "nowidow",
    "parnotes",
    "parskip",
    "placeins",
    "preprint",
    "sectsty",
    "soul",
    "titlesec",
    "titling",
    "units",
    "wasysym",
    "xstring",
]


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install TeX packages."""
    activate_app("curl", "gnupg", "wget", build_only=True)
    tlmgr = shutil.which("tlmgr")
    if tlmgr is None:
        msg = "tlmgr not found. Install TeX Live first."
        raise FileNotFoundError(msg)
    subprocess.run(["sudo", tlmgr, "update", "--self"], check=True)
    for pkg in _PACKAGES:
        print(f"Installing {pkg}.", file=sys.stderr)
        subprocess.run(["sudo", tlmgr, "install", pkg], check=True)
