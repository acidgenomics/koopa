"""Configurer registry for Python-native app configurers.

Maps (name, platform, mode) keys to Python modules containing a ``main()``
function that performs the configuration. Entries not in the registry fall
through to the existing Bash subshell configurer path.
"""

import importlib
from collections.abc import Callable

_M = "koopa.configurers"

PYTHON_CONFIGURERS: dict[tuple[str, str, str], str] = {
    # (name, platform, mode)
    ("color-mode", "common", "user"): f"{_M}.color_mode",
    ("doom-emacs", "common", "user"): f"{_M}.doom_emacs",
    ("dotfiles", "common", "user"): f"{_M}.dotfiles",
    ("emacs-prelude", "common", "user"): f"{_M}.emacs_prelude",
    ("spacemacs", "common", "user"): f"{_M}.spacemacs",
    ("lmod", "linux", "system"): f"{_M}.lmod",
    ("sshd", "common", "system"): f"{_M}.sshd",
    ("r", "common", "system"): f"{_M}.r",
    ("r", "macos", "system"): f"{_M}.r",
    ("r", "debian", "system"): f"{_M}.r",
    ("rstudio-server", "linux", "system"): f"{_M}.rstudio_server",
    ("base", "debian", "system"): f"{_M}.debian_base",
    ("preferences", "macos", "system"): f"{_M}.macos_system_preferences",
    ("preferences", "macos", "user"): f"{_M}.macos_user_preferences",
}


def has_python_configurer(name: str, platform: str, mode: str) -> bool:
    """Check if app has a Python-native configurer."""
    if (name, platform, mode) in PYTHON_CONFIGURERS:
        return True
    if platform != "common" and (name, "common", mode) in PYTHON_CONFIGURERS:
        return True
    return False


def get_python_configurer(
    name: str,
    platform: str,
    mode: str,
) -> Callable[..., None]:
    """Dynamically import and return the configurer's ``main`` function."""
    key = (name, platform, mode)
    if key not in PYTHON_CONFIGURERS:
        key = (name, "common", mode)
    module_path = PYTHON_CONFIGURERS[key]
    mod = importlib.import_module(module_path)
    return mod.main  # type: ignore[attr-defined]
