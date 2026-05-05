"""Uninstall RStudio Server on Fedora."""


import subprocess


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall RStudio Server on Fedora."""
    subprocess.run(
        ["sudo", "dnf", "remove", "-y", "rstudio-server"],
        check=False,
    )
