"""Install libksba."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libksba."""
    env = activate_app_deps()
    lgpe_prefix = app_prefix("libgpg-error")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            f"--prefix={prefix}",
            f"--with-libgpg-error-prefix={lgpe_prefix}",
        ],
        env=env,
    )
