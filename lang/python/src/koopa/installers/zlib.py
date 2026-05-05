"""Install zlib."""

from koopa.build import activate_app, make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import download_extract_cd, extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
    use_mirror: bool = False,
) -> None:
    """Install zlib."""
    env = activate_app("pkg-config", build_only=True)
    filename = f"zlib-{version}.tar.gz"
    url = f"https://www.zlib.net/{filename}"
    if use_mirror:
        tarball = download_with_mirror(url, name, filename)
        extract_cd(tarball)
    else:
        download_extract_cd(url)
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
    remove_static_libs(prefix)
