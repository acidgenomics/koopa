"""Install swig."""

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install swig."""
    env = activate_app_deps()
    pcre2_prefix = app_prefix("pcre2")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            f"--prefix={prefix}",
            f"--with-pcre2-prefix={pcre2_prefix}",
            "--without-alllang",
        ],
        env=env,
    )
