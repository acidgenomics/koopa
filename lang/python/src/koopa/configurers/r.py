"""Configure R."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile

from koopa.prefix import bash_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure R.

    This configurer delegates to the Bash implementation because it calls
    many R-specific Bash helper functions that haven't been ported yet.
    """
    script = os.path.join(bash_prefix(), "include", "configure", "common", "shared", "r.sh")
    if not os.path.isfile(script):
        msg = "R configure script not found."
        raise FileNotFoundError(msg)
    bash = shutil.which("bash")
    if bash is None:
        msg = "Bash is required."
        raise RuntimeError(msg)
    header = os.path.join(bash_prefix(), "include", "header.sh")
    tmp = tempfile.mkdtemp()
    try:
        cmd = f"source '{header}'; cd '{tmp}'; source '{script}'; main"
        env = os.environ.copy()
        env["KOOPA_INSTALL_NAME"] = name
        if verbose:
            env["KOOPA_VERBOSE"] = "1"
        flags = [
            bash,
            "--noprofile",
            "--norc",
            "-o",
            "errexit",
            "-o",
            "errtrace",
            "-o",
            "nounset",
            "-o",
            "pipefail",
        ]
        if verbose:
            flags.extend(["-o", "xtrace"])
        flags.extend(["-c", cmd])
        subprocess.run(flags, env=env, check=True)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
