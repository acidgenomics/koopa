"""Install pcre."""

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pcre."""
    env = activate_app_deps()
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-static",
            "--enable-pcre16",
            "--enable-pcre32",
            "--enable-pcre8",
            "--enable-pcregrep-libbz2",
            "--enable-pcregrep-libz",
            "--enable-unicode-properties",
            "--enable-utf8",
            f"--prefix={prefix}",
        ],
        env=env,
    )
