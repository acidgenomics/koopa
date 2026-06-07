"""Install xorg-libx11."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xorg-libx11."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-silent-rules",
            "--disable-static",
            "--enable-ipv6",
            "--enable-loadable-i18n",
            "--enable-specs=no",
            "--enable-tcp-transport",
            "--enable-unix-transport",
            "--enable-xthreads",
            f"--prefix={prefix}",
        ],
        env=env,
    )
