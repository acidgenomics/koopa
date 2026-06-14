"""Install 1password-cli."""

import os
import stat
import subprocess
import sys

from koopa.alert import warn
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
    """Install 1password-cli."""
    bin_dir = os.path.join(prefix, "bin")
    mkdir(bin_dir)
    machine = arch2()
    platform = "darwin" if sys.platform == "darwin" else "linux"
    url = (
        f"https://cache.agilebits.com/dist/1P/op2/pkg/v{version}/"
        f"op_{platform}_{machine}_v{version}.zip"
    )
    zipfile = download(url)
    extract(zipfile, bin_dir)
    op_bin = os.path.join(bin_dir, "op")
    os.chmod(op_bin, os.stat(op_bin).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    # Generate vendor shell completions (offline; op is a static binary).
    # Written into prefix share/etc dirs so install-time linking symlinks them
    # centrally and koopa's existing completion activation auto-loads them.
    bash_c = os.path.join(prefix, "etc", "bash_completion.d", "op")
    zsh_c = os.path.join(prefix, "share", "zsh", "site-functions", "_op")
    fish_c = os.path.join(prefix, "share", "fish", "vendor_completions.d", "op.fish")
    ps_c = os.path.join(prefix, "share", "powershell", "completions", "op.ps1")
    for path in (bash_c, zsh_c, fish_c, ps_c):
        mkdir(os.path.dirname(path))
    try:
        for args, out in (
            ([op_bin, "completion", "bash"], bash_c),
            ([op_bin, "completion", "zsh"], zsh_c),
            ([op_bin, "completion", "fish"], fish_c),
            ([op_bin, "completion", "powershell"], ps_c),
        ):
            with open(out, "w") as fh:
                subprocess.run(args, stdout=fh, check=True)
    except subprocess.CalledProcessError:
        # Best-effort: never abort a working install over completions.
        warn("Failed to generate 'op' shell completions.")
