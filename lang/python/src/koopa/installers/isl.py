"""Install isl."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install isl."""
    env = activate_app_deps()
    gmp_prefix = app_prefix("gmp")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
            "--with-gmp=system",
            f"--with-gmp-prefix={gmp_prefix}",
        ],
        env=env,
    )
