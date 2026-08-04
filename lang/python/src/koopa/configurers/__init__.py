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


def _candidate_platforms(platform: str) -> list[str]:
    """Return registry platform keys to try, most specific first.

    A caller-supplied concrete platform (e.g. ``macos``, ``debian``) is tried
    verbatim, then falls back to ``common``. The generic ``common`` platform
    expands to the current OS's specific id, its ``ID_LIKE`` family, its
    macos/linux family, and finally ``common`` itself -- so a registry entry
    keyed on the literal string ``"common"`` still resolves on a concrete
    host, while an explicit platform-specific entry (e.g. ``macos``) wins if
    both are registered.
    """
    if platform != "common":
        return [platform, "common"]
    from koopa.system import get_os_id, get_os_id_like, is_macos

    candidates = [get_os_id()]
    candidates.extend(get_os_id_like().split())
    candidates.append("macos" if is_macos() else "linux")
    candidates.append("common")
    return list(dict.fromkeys(c for c in candidates if c))


def _resolve_key(name: str, platform: str, mode: str) -> tuple[str, str, str] | None:
    """Return the first matching registry key, or ``None`` if none match."""
    for candidate in _candidate_platforms(platform):
        key = (name, candidate, mode)
        if key in PYTHON_CONFIGURERS:
            return key
    return None


def has_python_configurer(name: str, platform: str, mode: str) -> bool:
    """Check if app has a Python-native configurer."""
    return _resolve_key(name, platform, mode) is not None


def get_python_configurer(
    name: str,
    platform: str,
    mode: str,
) -> Callable[..., None]:
    """Dynamically import and return the configurer's ``main`` function."""
    key = _resolve_key(name, platform, mode)
    if key is None:
        raise KeyError((name, platform, mode))
    module_path = PYTHON_CONFIGURERS[key]
    mod = importlib.import_module(module_path)
    return mod.main  # type: ignore[attr-defined]
