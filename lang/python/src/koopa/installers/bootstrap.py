"""Install koopa bootstrap."""

from __future__ import annotations

import subprocess

from koopa.prefix import koopa_prefix


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install koopa bootstrap."""
    script = f"{koopa_prefix()}/etc/koopa/bootstrap.sh"
    subprocess.run(
        [script],
        check=True,
    )
