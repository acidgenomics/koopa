"""Install apache-spark."""

from __future__ import annotations

import os
import stat

from koopa.archive import extract
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install apache-spark."""
    url = f"https://archive.apache.org/dist/spark/spark-{version}/spark-{version}-bin-hadoop3.tgz"
    tarball = download(url)
    libexec = os.path.join(prefix, "libexec")
    extract(tarball, libexec)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    for cmd in ("pyspark", "sparkR"):
        wrapper = os.path.join(bin_dir, cmd)
        with open(wrapper, "w") as fh:
            fh.write(f"""\
#!/bin/sh
export SPARK_HOME="{libexec}"
exec "{libexec}/bin/{cmd}" "$@"
""")
        os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IEXEC)
