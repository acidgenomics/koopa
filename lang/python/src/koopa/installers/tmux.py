"""Install tmux."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tmux."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--enable-sixel",
            "--enable-utf8proc",
            f"--prefix={prefix}",
        ],
        env=env,
    )
