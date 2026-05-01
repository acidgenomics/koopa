"""Install dotfiles."""

from __future__ import annotations

import subprocess


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install dotfiles."""
    url = "https://github.com/acidgenomics/dotfiles.git"
    subprocess.run(
        [
            "git",
            "clone",
            "--depth=1",
            f"--branch={version}",
            url,
            prefix,
        ],
        check=True,
    )
