"""Install libpng."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libpng."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-shared=yes",
            f"--prefix={prefix}",
        ],
        env=env,
    )
