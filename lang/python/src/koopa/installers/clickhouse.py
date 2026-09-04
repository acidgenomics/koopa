"""Install clickhouse."""

import os
import stat
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import mkdir
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install clickhouse.

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
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    if sys.platform == "darwin":
        machine = arch2()
        # macOS: single static binary (no tarball)
        suffix = "-aarch64" if machine == "arm64" else ""
        url = (
            f"https://github.com/ClickHouse/ClickHouse/releases/download/"
            f"v{version}-stable/clickhouse-macos{suffix}"
        )
        dest = os.path.join(bin_dir, "clickhouse")
        download(url, dest)
        os.chmod(dest, os.stat(dest).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    else:
        machine = arch2()
        arch_slug = "arm64" if machine == "arm64" else "amd64"
        url = (
            f"https://github.com/ClickHouse/ClickHouse/releases/download/"
            f"v{version}-stable/clickhouse-common-static-{version}-{arch_slug}.tgz"
        )
        tarball = download(url)
        extract(tarball, prefix)
        # The tarball extracts to clickhouse-common-static-{version}/usr/bin/clickhouse
        extracted_bin = os.path.join(
            prefix,
            f"clickhouse-common-static-{version}",
            "usr",
            "bin",
            "clickhouse",
        )
        dest = os.path.join(bin_dir, "clickhouse")
        os.symlink(extracted_bin, dest)
