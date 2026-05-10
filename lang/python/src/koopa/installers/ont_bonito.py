"""Install ONT Bonito."""

from koopa.install import install_python_package
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ONT Bonito."""
    env = activate_app_deps()
    install_python_package(
        name=name,
        version=version,
        prefix=prefix,
        egg_name="ont_bonito",
        python_version="3.13",
    )
