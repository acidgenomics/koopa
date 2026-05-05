"""Install axel."""

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install axel."""
    env = activate_app("gawk", "pkg-config", build_only=True)
    env = activate_app("gettext", "openssl", env=env)
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-silent-rules",
            f"--prefix={prefix}",
        ],
        env=env,
    )
