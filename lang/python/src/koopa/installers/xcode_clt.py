"""Install xcode-clt."""

from __future__ import annotations

import os
import subprocess
import sys


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xcode-clt."""
    clt_dir = "/Library/Developer/CommandLineTools"
    if os.path.isdir(clt_dir):
        print("Removing old Xcode CLT installation.", file=sys.stderr)
        subprocess.run(["sudo", "rm", "-rf", clt_dir], check=True)
    print("Installing Xcode Command Line Tools...", file=sys.stderr)
    print("Follow the prompts in the dialog window.", file=sys.stderr)
    subprocess.run(["xcode-select", "--install"], check=False)
    input("Press Enter after installation completes...")
    if os.path.isdir(clt_dir):
        subprocess.run(
            ["sudo", "xcodebuild", "-license", "accept"],
            check=False,
        )
        subprocess.run(
            ["sudo", "xcode-select", "--reset"],
            check=True,
        )
