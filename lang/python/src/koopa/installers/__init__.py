"""Installer registry for Python-native app installers.

Maps app names to Python modules containing a ``main()`` function that
performs the installation. Apps not in the registry fall through to the
existing Bash subshell installer path.
"""

from __future__ import annotations

import importlib
from collections.abc import Callable

PYTHON_INSTALLERS: dict[str, str] = {}


def has_python_installer(name: str) -> bool:
    """Check if app has a Python-native installer."""
    return name in PYTHON_INSTALLERS


def get_python_installer(
    name: str,
) -> Callable[..., None]:
    """Dynamically import and return the installer's ``main`` function."""
    module_path = PYTHON_INSTALLERS[name]
    mod = importlib.import_module(module_path)
    return mod.main  # type: ignore[attr-defined]
