"""Install nano."""

from koopa.build import activate_app, make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import download_extract_cd, extract_cd


def _major_version(version: str) -> str:
    return version.split(".", maxsplit=1)[0]


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
    use_mirror: bool = False,
) -> None:
    """Install nano."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("gettext", "ncurses", env=env)
    maj = _major_version(version)
    filename = f"nano-{version}.tar.xz"
    url = f"https://www.nano-editor.org/dist/v{maj}/{filename}"
    if use_mirror:
        tarball = download_with_mirror(url, name, filename)
        extract_cd(tarball)
    else:
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
