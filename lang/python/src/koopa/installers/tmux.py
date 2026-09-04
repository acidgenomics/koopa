"""Install tmux."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd
from koopa.system import is_macos


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tmux.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    env = activate_app_deps()
    download_extract_cd()
    conf_args = [
        "--enable-sixel",
        "--enable-utf8proc",
        f"--prefix={prefix}",
    ]
    if is_macos():
        # macOS calloc(3) does not always zero memory correctly. Upstream's
        # configure hard-errors on darwin unless one of --enable-jemalloc or
        # --disable-jemalloc is given; build against jemalloc as Homebrew does.
        conf_args.append("--enable-jemalloc")
    make_build(conf_args=conf_args, env=env)
