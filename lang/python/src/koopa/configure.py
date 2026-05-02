"""Application configuration functions.

Provides ``configure_app`` -- the Python equivalent of the Bash function
``_koopa_configure_app``.
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass

from koopa.configurers import get_python_configurer, has_python_configurer
from koopa.prefix import koopa_prefix


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
    if os.getuid() == 0:
        return True
    if sys.platform == "darwin":
        import grp

        try:
            return grp.getgrnam("admin").gr_gid in os.getgroups()
        except KeyError:
            return False
    return False


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
    if not has_python_configurer(config.name, config.platform, config.mode):
        msg = f"No configurer for '{config.name}' ({config.platform}/{config.mode})."
        raise FileNotFoundError(msg)
    configurer = get_python_configurer(config.name, config.platform, config.mode)
    configurer(
        name=config.name,
        platform=config.platform,
        mode=config.mode,
        verbose=config.verbose,
    )
    print(f"Successfully configured '{config.name}'.", file=sys.stderr)
