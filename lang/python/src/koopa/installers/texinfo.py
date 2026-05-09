"""Install texinfo."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install texinfo."""
    env = activate_app("make", build_only=True)
    env = activate_app("gettext", "libiconv", "ncurses", "perl", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-nls",
            "--disable-perl-xs",
            f"--prefix={prefix}",
        ],
        env=env,
    )
