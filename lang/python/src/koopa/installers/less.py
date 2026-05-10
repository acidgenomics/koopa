"""Install less."""

import subprocess

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install less."""
    env = activate_app_deps()
    download_extract_cd()
    subprocess_env = env.to_env_dict()
    subprocess.run(
        ["make", "-f", "Makefile.aut", "distfiles"],
        env=subprocess_env,
        check=True,
    )
    make_build(
        conf_args=[
            f"--prefix={prefix}",
            "--with-regex=pcre2",
        ],
        env=env,
    )
