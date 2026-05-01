"""Man page display utility for koopa CLI help system."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.prefix import man_prefix


def show_man_page(*parts: str) -> None:
    """Display man page for a koopa subcommand."""
    man_dir = os.path.join(man_prefix(), "man1")
    man_file = os.path.join(man_dir, "koopa", *parts[:-1], f"{parts[-1]}.1") if parts else ""
    if not man_file or not os.path.isfile(man_file):
        man_file = os.path.join(man_dir, "koopa.1")
    if not os.path.isfile(man_file):
        print(f"No manual entry for 'koopa {' '.join(parts)}'.", file=sys.stderr)
        sys.exit(1)
    subprocess.run(["man", man_file], check=False)
