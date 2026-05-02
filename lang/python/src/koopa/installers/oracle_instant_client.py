"""Install oracle-instant-client."""

from __future__ import annotations

import subprocess

from koopa.download import download
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install oracle-instant-client."""
    machine = arch()
    ver_parts = version.replace("-", ".").split(".")
    ver_stem = "".join(ver_parts[:4])
    major = ver_parts[0]
    base_url = f"https://download.oracle.com/otn_software/linux/instantclient/{ver_stem}"
    packages = [
        "basic",
        "devel",
        "sqlplus",
        "jdbc",
        "odbc",
    ]
    for pkg in packages:
        url = f"{base_url}/oracle-instantclient{major}-{pkg}-{version}.{machine}.rpm"
        rpm_file = download(url)
        subprocess.run(["sudo", "rpm", "-ivh", rpm_file], check=False)
