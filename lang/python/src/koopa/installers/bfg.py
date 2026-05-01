"""Install bfg."""

from __future__ import annotations

import os
import stat

from koopa.build import activate_app, locate
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bfg."""
    env = activate_app("temurin")
    java = locate("java")
    libexec = os.path.join(prefix, "libexec")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(libexec, exist_ok=True)
    os.makedirs(bin_dir, exist_ok=True)
    jar_name = f"bfg-{version}.jar"
    url = (
        f"https://repo1.maven.org/maven2/com/madgag/bfg/"
        f"{version}/{jar_name}"
    )
    download(url, output=os.path.join(libexec, jar_name))
    wrapper = os.path.join(bin_dir, "bfg")
    with open(wrapper, "w") as fh:
        fh.write(f"""\
#!/bin/sh
exec {java} -jar "{libexec}/{jar_name}" "$@"
""")
    os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IEXEC)
