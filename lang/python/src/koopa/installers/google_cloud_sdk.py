"""Install google-cloud-sdk."""

from __future__ import annotations

import glob
import os

from koopa.install import install_conda_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install google-cloud-sdk."""
    kwargs = parse_passthrough(passthrough_args)
    install_conda_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
    )
    _setup_completions(prefix)


def _setup_completions(prefix: str) -> None:
    """Symlink gcloud completion files into standard locations within the prefix.

    gcloud ships ``completion.bash.inc`` and ``completion.zsh.inc`` inside a
    versioned subdirectory such as
    ``libexec/share/google-cloud-sdk-566.0.0-0/``.  We:

    1. Create a stable symlink ``libexec/gcloud`` → the versioned subdir so
       the zsh activation function can reference a fixed path.
    2. Symlink ``completion.bash.inc`` into
       ``share/bash-completion/completions/gcloud`` so bash-completion v2
       lazy-loads it on first TAB after ``gcloud``.
    """
    prefix = os.path.abspath(prefix)
    matches = sorted(glob.glob(os.path.join(prefix, "libexec", "share", "google-cloud-sdk-*")))
    if not matches:
        return
    sdk_dir = matches[-1]  # most recent if multiple

    # Stable symlink libexec/gcloud → versioned subdir.
    stable = os.path.join(prefix, "libexec", "gcloud")
    if os.path.islink(stable):
        os.unlink(stable)
    os.symlink(sdk_dir, stable)

    # Bash: symlink completion.bash.inc into standard location.
    bash_inc = os.path.join(sdk_dir, "completion.bash.inc")
    if os.path.isfile(bash_inc):
        bash_dir = os.path.join(prefix, "share", "bash-completion", "completions")
        os.makedirs(bash_dir, exist_ok=True)
        bash_target = os.path.join(bash_dir, "gcloud")
        if os.path.islink(bash_target):
            os.unlink(bash_target)
        os.symlink(bash_inc, bash_target)
