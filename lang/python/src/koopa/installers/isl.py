"""Install isl."""

from koopa.build import activate_app, app_prefix, make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import download_extract_cd, extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
    use_mirror: bool = False,
) -> None:
    """Install isl."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("gmp", env=env)
    gmp_prefix = app_prefix("gmp")
    filename = f"isl-{version}.tar.xz"
    primary_url = f"https://downloads.sourceforge.net/project/libisl/{filename}"
    if use_mirror:
        tarball = download_with_mirror(primary_url, name, filename)
        extract_cd(tarball)
    else:
        download_extract_cd(primary_url)
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
