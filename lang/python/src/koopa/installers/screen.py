"""Install screen."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install screen."""
    env = activate_app("ncurses", "libxcrypt", env=None)
    download_extract_cd()
    conf_args = [
        "--enable-colors256",
        f"--prefix={prefix}",
    ]
    make_build(conf_args=conf_args, env=env)
