"""Install xorg-libxcb."""

from koopa.build import locate, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xorg-libxcb."""
    env = activate_app_deps()
    python = locate("python3")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-devel-docs=no",
            "--enable-dri3",
            "--enable-ge",
            "--enable-selinux",
            "--enable-xevie",
            "--enable-xprint",
            f"--prefix={prefix}",
            "--with-doxygen=no",
            f"PYTHON={python}",
        ],
        env=env,
    )
