"""Install libxslt."""

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libxslt."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("icu4c", "libxml2", "libgpg-error", "libgcrypt", env=env)
    libxml2_prefix = app_prefix("libxml2")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--with-crypto",
            f"--with-libxml-prefix={libxml2_prefix}",
            "--without-python",
            f"--prefix={prefix}",
        ],
        env=env,
    )
