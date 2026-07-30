"""Install nghttp2."""

from koopa.build import locate, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nghttp2."""
    env = activate_app_deps()
    python = locate("python3")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-silent-rules",
            "--disable-static",
            "--enable-lib-only",
            f"PYTHON={python}",
            f"--prefix={prefix}",
        ],
        env=env,
    )
