"""Install libxslt."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libxslt."""
    env = activate_app_deps()
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
