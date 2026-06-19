"""Install bash-preexec."""

import os
import shutil

from koopa.download import download_with_mirror


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install bash-preexec."""
    url = f"https://raw.githubusercontent.com/rcaloras/bash-preexec/{version}/bash-preexec.sh"
    script = download_with_mirror(url, name, "bash-preexec.sh")
    share_dir = os.path.join(prefix, "share", "bash-preexec")
    os.makedirs(share_dir, exist_ok=True)
    shutil.copy2(script, os.path.join(share_dir, "bash-preexec.sh"))
