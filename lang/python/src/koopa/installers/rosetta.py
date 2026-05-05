"""Install Rosetta 2 on macOS."""

import subprocess


def main(*, name: str, **kwargs) -> None:
    """Install Rosetta 2 via softwareupdate."""
    subprocess.run(
        ["softwareupdate", "--install-rosetta", "--agree-to-license"],
        check=True,
    )
