"""Install apr."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install apr."""
    env = activate_app("pkg-config", build_only=True)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
