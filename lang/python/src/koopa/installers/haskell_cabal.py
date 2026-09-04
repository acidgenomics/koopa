"""Install haskell-cabal."""

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
    """Install haskell-cabal.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    ghcup = locate("ghcup")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    subprocess.run(
        [ghcup, "install", "cabal", version, "--isolate", bin_dir],
        check=True,
    )
