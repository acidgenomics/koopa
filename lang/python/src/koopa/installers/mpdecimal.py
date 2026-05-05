"""Install mpdecimal."""

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install mpdecimal."""
    download_extract_cd()
    make_build(
        conf_args=["--disable-static", f"--prefix={prefix}"],
    )
    remove_static_libs(prefix)
