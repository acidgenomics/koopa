"""Install gum."""

from __future__ import annotations

import os
import subprocess

from koopa.install import build_go_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gum."""
    url = f"https://github.com/charmbracelet/gum/archive/v{version}.tar.gz"
    ldflags = f"-s -w -X main.Version={version}"
    build_go_package(
        url=url,
        name=name,
        version=version,
        prefix=prefix,
        ldflags=ldflags,
    )
    gum = os.path.join(prefix, "bin", "gum")
    bash_c = os.path.join(prefix, "etc", "bash_completion.d", "gum")
    fish_c = os.path.join(prefix, "share", "fish", "vendor_completions.d", "gum.fish")
    zsh_c = os.path.join(prefix, "share", "zsh", "site-functions", "_gum")
    manfile = os.path.join(prefix, "share", "man", "man1", "gum.1")
    for path in (bash_c, fish_c, zsh_c, manfile):
        os.makedirs(os.path.dirname(path), exist_ok=True)
    for args, out in [
        ([gum, "completion", "bash"], bash_c),
        ([gum, "completion", "fish"], fish_c),
        ([gum, "completion", "zsh"], zsh_c),
        ([gum, "man"], manfile),
    ]:
        with open(out, "w") as fh:
            subprocess.run(args, stdout=fh, check=True)
