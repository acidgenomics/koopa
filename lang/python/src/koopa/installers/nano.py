"""Install nano."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def _major_version(version: str) -> str:
    return version.split(".", maxsplit=1)[0]


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nano."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("gettext", "ncurses", env=env)
    maj = _major_version(version)
    url = f"https://www.nano-editor.org/dist/v{maj}/nano-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-debug",
            "--disable-dependency-tracking",
            "--enable-color",
            "--enable-extra",
            "--enable-multibuffer",
            "--enable-nanorc",
            "--enable-utf8",
            f"--prefix={prefix}",
        ],
        env=env,
    )
