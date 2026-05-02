"""Conda environment management functions.

Converted from Bash functions in ``lang/bash/functions/core/conda-*.sh``.
"""

from __future__ import annotations

import os
import shutil
import subprocess


def _conda(*args: str, capture: bool = True) -> subprocess.CompletedProcess:
    """Run a conda command."""
    conda = shutil.which("conda")
    if conda is None:
        msg = "conda is not installed."
        raise RuntimeError(msg)
    return subprocess.run(
        [conda, *args], capture_output=capture, text=True, check=True,
    )


def conda_create_env(
    *packages: str,
    prefix: str = "",
    yaml_file: str = "",
    force: bool = False,
    latest: bool = False,
) -> None:
    """Create a conda environment."""
    conda = shutil.which("conda")
    if conda is None:
        msg = "conda is not installed."
        raise RuntimeError(msg)
    if yaml_file:
        if not os.path.isfile(yaml_file):
            msg = f"YAML file not found: '{yaml_file}'."
            raise FileNotFoundError(msg)
        cmd = [conda, "env", "create", "--file", yaml_file, "--quiet"]
        if prefix:
            cmd.extend(["--prefix", prefix])
        subprocess.run(cmd, check=True)
        return
    if prefix and packages:
        cmd = [conda, "create", "--prefix", prefix, "--quiet", "--yes"]
        cmd.extend(packages)
        subprocess.run(cmd, check=True)
        return
    for pkg in packages:
        env_string = pkg.replace("@", "=")
        if "=" in env_string:
            parts = env_string.split("=", 2)
            env_name = f"{parts[0]}@{parts[1]}"
        else:
            env_name = env_string
        print(f"Creating conda environment '{env_name}'.")
        cmd = [conda, "create", f"--name={env_name}", "--quiet", "--yes"]
        cmd.append(env_string)
        subprocess.run(cmd, check=True)


def conda_remove_env(*names: str) -> None:
    """Remove conda environments."""
    conda = shutil.which("conda")
    if conda is None:
        msg = "conda is not installed."
        raise RuntimeError(msg)
    for name in names:
        print(f"Removing conda environment '{name}'.")
        subprocess.run(
            [conda, "env", "remove", f"--name={name}", "--yes"],
            check=True,
        )
