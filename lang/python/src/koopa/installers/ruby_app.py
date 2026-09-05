"""Install ruby."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd
from koopa.system import is_macos


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ruby.

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
        "--disable-install-doc",
        "--disable-silent-rules",
        "--enable-load-relative",
        "--enable-shared",
        f"--prefix={prefix}",
        f"--with-libffi-dir={app_prefix('libffi')}",
        f"--with-libyaml-dir={app_prefix('libyaml')}",
        f"--with-openssl-dir={app_prefix('openssl3')}",
        f"--with-readline-dir={app_prefix('readline')}",
        f"--with-zlib-dir={app_prefix('zlib')}",
        "--without-gmp",
    ]
    if is_macos():
        conf_args.append("--enable-dtrace")
    make_build(conf_args=conf_args, env=env)
