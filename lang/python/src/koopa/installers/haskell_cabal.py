"""Install haskell-cabal."""

from __future__ import annotations

import os
import subprocess

from koopa.build import locate


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install haskell-cabal."""
    ghcup = locate("ghcup")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    subprocess.run(
        [ghcup, "install", "cabal", version, "--isolate", bin_dir],
        check=True,
    )
