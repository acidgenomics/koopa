"""Install uv."""

from __future__ import annotations

import os
import stat
import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install uv."""
    script = download("https://astral.sh/uv/install.sh", output="uv-install.sh")
    os.chmod(script, os.stat(script).st_mode | stat.S_IEXEC)
    env = os.environ.copy()
    env["UV_NO_MODIFY_PATH"] = "1"
    env["UV_PRINT_VERBOSE"] = "1"
    env["UV_UNMANAGED_INSTALL"] = os.path.join(prefix, "bin")
    subprocess.run(
        ["bash", script],
        env=env,
        check=True,
    )
