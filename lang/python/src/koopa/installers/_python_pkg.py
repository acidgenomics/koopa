"""Generic Python package installer."""

from koopa.install import install_python_package
from koopa.installers._args import get_dict, get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Python package."""
    kwargs = parse_passthrough(passthrough_args)
    extra = get_list(kwargs, "extra_packages")
    build_env = get_dict(kwargs, "build_env")
    install_python_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        pip_name=get_str(kwargs, "pip_name"),
        egg_name=get_str(kwargs, "egg_name"),
        python_version=get_str(kwargs, "python_version"),
        extra_packages=extra or None,
        no_binary=get_str(kwargs, "no_binary") == "true",
        build_env=build_env or None,
    )
