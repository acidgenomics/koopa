"""Install tmux."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tmux."""
    env = activate_app("bison", "pkg-config", build_only=True)
    env = activate_app("libevent", "ncurses", "utf8proc", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--enable-utf8proc",
            f"--prefix={prefix}",
        ],
        env=env,
    )
