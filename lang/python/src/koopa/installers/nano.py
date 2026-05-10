"""Install nano."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nano."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("ncurses", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-debug",
            "--disable-dependency-tracking",
            "--disable-nls",
            "--enable-color",
            "--enable-extra",
            "--enable-multibuffer",
            "--enable-nanorc",
            "--enable-utf8",
            f"--prefix={prefix}",
        ],
        env=env,
    )
