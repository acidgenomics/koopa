"""Install ensembl-perl-api."""

from __future__ import annotations

import os
import subprocess


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ensembl-perl-api."""
    repos = [
        ("bioperl-live", "release-1-6-924"),
        ("ensembl-git-tools", "main"),
        ("ensembl", f"release/{version}"),
        ("ensembl-compara", f"release/{version}"),
        ("ensembl-funcgen", f"release/{version}"),
        ("ensembl-io", f"release/{version}"),
        ("ensembl-variation", f"release/{version}"),
    ]
    for repo_name, branch in repos:
        if repo_name == "bioperl-live":
            org = "bioperl"
        elif repo_name == "ensembl-git-tools":
            org = "Ensembl"
        else:
            org = "Ensembl"
        url = f"https://github.com/{org}/{repo_name}.git"
        dest = os.path.join(prefix, repo_name)
        subprocess.run(
            [
                "git", "clone",
                "--depth=1",
                f"--branch={branch}",
                url,
                dest,
            ],
            check=True,
        )
