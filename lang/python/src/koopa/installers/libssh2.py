"""Install libssh2."""

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
    """Install libssh2."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "openssl", env=env)
    openssl_prefix = app_prefix("openssl")
    zlib_prefix = app_prefix("zlib")
    filename = f"libssh2-{version}.tar.gz"
    primary_url = f"https://www.libssh2.org/download/{filename}"
    if use_mirror:
        tarball = download_with_mirror(primary_url, name, filename)
        extract_cd(tarball)
    else:
        download_extract_cd(primary_url)
    make_build(
        conf_args=[
            "--disable-examples-build",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
            "--with-crypto=openssl",
            f"--with-libssl-prefix={openssl_prefix}",
            f"--with-libz-prefix={zlib_prefix}",
        ],
        env=env,
    )
