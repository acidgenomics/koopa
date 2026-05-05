"""Install nim."""

import subprocess

from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nim."""
    download_extract_cd()
    subprocess.run(["sh", "build.sh"], check=True)
    subprocess.run(
        ["bin/nim", "c", "-d:release", "koch"],
        check=True,
    )
    subprocess.run(
        ["./koch", "boot", "-d:release"],
        check=True,
    )
    subprocess.run(
        ["./koch", "tools"],
        check=True,
    )
    subprocess.run(
        ["sh", "install.sh", prefix],
        check=True,
    )
