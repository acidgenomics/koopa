"""Install swig."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install swig."""
    env = activate_app("pcre2", env=None)
    pcre2_prefix = app_prefix("pcre2")
    url = f"https://koopa.acidgenomics.com/src/swig/{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            f"--prefix={prefix}",
            f"--with-pcre2-prefix={pcre2_prefix}",
            "--without-alllang",
        ],
        env=env,
    )
