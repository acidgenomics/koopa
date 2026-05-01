"""Install lesspipe."""

from __future__ import annotations

from koopa.build import activate_app, locate, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install lesspipe."""
    env = activate_app("bash", build_only=True)
    bash = locate("bash")
    url = (
        f"https://github.com/wofr06/lesspipe/archive/"
        f"refs/tags/v{version}.tar.gz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            f"--bash-completion-dir={prefix}/etc/bash_completion.d",
            f"--prefix={prefix}",
            f"--shell={bash}",
            f"--zsh-completion-dir={prefix}/share/zsh/site-functions",
        ],
        env=env,
    )
