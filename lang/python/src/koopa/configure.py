"""Application configuration functions.

Provides ``configure_app`` -- the Python equivalent of the Bash function
``_koopa_configure_app``. Sources configure scripts from
``lang/bash/include/configure/{platform}/{mode}/{name}.sh`` and calls
``main()`` in an isolated subshell.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass

from koopa.configurers import get_python_configurer, has_python_configurer
from koopa.prefix import bash_prefix, koopa_prefix


@dataclass
class ConfigureConfig:
    """Configuration for application configuration."""

    name: str
    mode: str = "shared"
    platform: str = "common"
    verbose: bool = False


def _is_owner() -> bool:
    """Check if current user is the koopa installation owner."""
    try:
        return os.stat(koopa_prefix()).st_uid == os.getuid()
    except OSError:
        return False


def _is_admin() -> bool:
    """Check if current user has admin/root access."""
    return os.getuid() == 0


def configure_app(config: ConfigureConfig) -> None:
    """Configure an application in an isolated subshell."""
    if config.verbose:
        os.environ["KOOPA_VERBOSE"] = "1"
    if config.mode == "shared":
        if not _is_owner():
            msg = "Only the koopa owner can configure shared apps."
            raise PermissionError(msg)
    elif config.mode == "system":
        if not _is_owner():
            msg = "Only the koopa owner can configure system apps."
            raise PermissionError(msg)
        if not _is_admin():
            msg = "Admin/root access required for system configuration."
            raise PermissionError(msg)
    elif config.mode == "user" and _is_admin():
        msg = "Root user cannot configure user apps."
        raise PermissionError(msg)
    print(f"Configuring '{config.name}'.", file=sys.stderr)
    if has_python_configurer(config.name, config.platform, config.mode):
        configurer = get_python_configurer(config.name, config.platform, config.mode)
        configurer(
            name=config.name,
            platform=config.platform,
            mode=config.mode,
            verbose=config.verbose,
        )
    else:
        config_file = os.path.join(
            bash_prefix(),
            "include",
            "configure",
            config.platform,
            config.mode,
            f"{config.name}.sh",
        )
        if not os.path.isfile(config_file):
            msg = f"No configure script for '{config.name}' ({config.platform}/{config.mode})."
            raise FileNotFoundError(msg)
        _run_configure_script(config_file, config)
    print(f"Successfully configured '{config.name}'.", file=sys.stderr)


def _run_configure_script(
    script_path: str,
    config: ConfigureConfig,
) -> None:
    """Run a Bash configure script in an isolated subshell."""
    bash = shutil.which("bash")
    if bash is None:
        msg = "Bash is required to run configure scripts."
        raise RuntimeError(msg)
    header_file = os.path.join(bash_prefix(), "include", "header.sh")
    tmp_dir = tempfile.mkdtemp()
    try:
        parts = [
            f"source '{header_file}'",
            f"cd '{tmp_dir}'",
            f"source '{script_path}'",
            "main",
        ]
        if config.mode == "system":
            parts.insert(1, 'PATH="${PATH}:/usr/sbin:/sbin"')
        cmd = "; ".join(parts)
        env = os.environ.copy()
        env["KOOPA_INSTALL_NAME"] = config.name
        flags = [
            bash,
            "--noprofile",
            "--norc",
            "-o",
            "errexit",
            "-o",
            "errtrace",
            "-o",
            "nounset",
            "-o",
            "pipefail",
        ]
        if config.verbose:
            flags.append("-o")
            flags.append("xtrace")
        flags.extend(["-c", cmd])
        subprocess.run(flags, env=env, check=True)
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)
