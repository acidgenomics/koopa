"""Install a Python package as a plugin into a parent app's venv."""

import os
import subprocess

from koopa.installers._args import get_str, parse_passthrough
from koopa.prefix import opt_prefix


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Python package into a parent app's existing venv."""
    kwargs = parse_passthrough(passthrough_args)
    parent_app = get_str(kwargs, "parent_app")
    if not parent_app:
        raise ValueError(f"{name}: installer_args.parent_app is required")
    pip_name = get_str(kwargs, "pip_name") or name
    parent_opt = os.path.join(opt_prefix(), parent_app)
    parent_prefix = os.path.realpath(parent_opt)
    venv_pip = os.path.join(parent_prefix, "libexec", "bin", "pip")
    if not os.path.isfile(venv_pip):
        raise FileNotFoundError(
            f"{name}: parent app '{parent_app}' venv not found at {venv_pip!r}; "
            f"install {parent_app} first"
        )
    subprocess.run(
        [venv_pip, "install", "--no-cache-dir", f"{pip_name}=={version}"],
        check=True,
    )
