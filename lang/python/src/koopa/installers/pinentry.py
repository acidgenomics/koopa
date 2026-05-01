"""Install pinentry."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pinentry."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libiconv", "ncurses", "libgpg-error", "libassuan", env=env)
    lgpe_prefix = app_prefix("libgpg-error")
    libassuan_prefix = app_prefix("libassuan")
    libiconv_prefix = app_prefix("libiconv")
    ncurses_prefix = app_prefix("ncurses")
    gcrypt_url = "https://gnupg.org/ftp/gcrypt"
    url = f"{gcrypt_url}/pinentry/pinentry-{version}.tar.bz2"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-inside-emacs",
            "--disable-libsecret",
            "--disable-pinentry-efl",
            "--disable-pinentry-emacs",
            "--disable-pinentry-fltk",
            "--disable-pinentry-gnome3",
            "--disable-pinentry-gtk2",
            "--disable-pinentry-qt",
            "--disable-pinentry-qt4",
            "--disable-pinentry-qt5",
            "--disable-pinentry-tqt",
            "--disable-silent-rules",
            "--enable-pinentry-tty",
            f"--prefix={prefix}",
            f"--with-libassuan-prefix={libassuan_prefix}",
            f"--with-libgpg-error-prefix={lgpe_prefix}",
            f"--with-libiconv-prefix={libiconv_prefix}",
            f"--with-ncurses-include-dir={ncurses_prefix}/include",
        ],
        env=env,
    )
