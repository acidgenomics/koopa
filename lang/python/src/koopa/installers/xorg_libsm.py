"""Install xorg-libsm."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xorg-libsm."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("xorg-xorgproto", "xorg-xtrans", "xorg-libice", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-docs=no",
            f"--prefix={prefix}",
        ],
        env=env,
    )
