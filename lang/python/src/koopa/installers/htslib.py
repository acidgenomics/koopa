"""Install htslib."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install htslib."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--enable-gcs",
            "--enable-libcurl",
            "--enable-plugins",
            "--enable-s3",
            f"--prefix={prefix}",
            "--with-libdeflate",
        ],
        env=env,
    )
