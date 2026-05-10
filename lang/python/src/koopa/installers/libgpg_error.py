"""Install libgpg-error."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libgpg-error."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--enable-install-gpg-error-config",
            f"--prefix={prefix}",
        ],
        env=env,
    )
