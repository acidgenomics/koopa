"""Install koopa bootstrap."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.prefix import bootstrap_prefix, koopa_prefix


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install koopa bootstrap."""
    script = os.path.join(koopa_prefix(), "bootstrap.sh")
    subprocess.run([script], check=True)
    # The bootstrap.sh we just ran atomically replaced the bootstrap
    # directory.  If the current interpreter lives inside that directory
    # (e.g. during `koopa update` on a shared/builder install), its stdlib
    # paths are now stale and any subsequent `import koopa.*` will fail with
    # "No module named 'koopa'".  Exec-restart using the freshly-built Python
    # before returning to the caller, preserving all CLI arguments.
    bp = bootstrap_prefix()
    new_python = os.path.join(bp, "bin", "python3")
    if (
        os.path.isfile(new_python)
        and sys.executable != new_python
        and sys.executable.startswith(bp + os.sep)
    ):
        # Ensure the koopa source tree is on PYTHONPATH so the restarted
        # process can import koopa (bin-helper.sh sets this when running from
        # bootstrap Python, but be defensive here).
        src = os.path.join(koopa_prefix(), "lang", "python", "src")
        existing = os.environ.get("PYTHONPATH", "")
        if src not in existing.split(os.pathsep):
            os.environ["PYTHONPATH"] = f"{src}{os.pathsep}{existing}".rstrip(os.pathsep)
        os.execv(new_python, [new_python] + sys.argv)
