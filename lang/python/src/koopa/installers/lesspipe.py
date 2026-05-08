"""Install lesspipe."""

from koopa.build import locate, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install lesspipe."""
    bash = locate("bash")
    download_extract_cd()
    make_build(
        conf_args=[
            f"--bash-completion-dir={prefix}/etc/bash_completion.d",
            f"--prefix={prefix}",
            f"--shell={bash}",
            f"--zsh-completion-dir={prefix}/share/zsh/site-functions",
        ],
    )
