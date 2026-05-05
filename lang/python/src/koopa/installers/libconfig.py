"""Install libconfig."""

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libconfig."""
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            f"--prefix={prefix}",
        ],
    )
