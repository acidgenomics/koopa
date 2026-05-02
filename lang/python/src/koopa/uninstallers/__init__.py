"""Uninstaller registry for Python-native app uninstallers.

Maps (name, platform, mode) keys to Python modules containing a ``main()``
function that performs the uninstallation. Entries not in the registry fall
through to the existing Bash subshell uninstaller path.
"""

from __future__ import annotations

import importlib
from collections.abc import Callable

_M = "koopa.uninstallers"

PYTHON_UNINSTALLERS: dict[tuple[str, str, str], str] = {
    # (name, platform, mode)
    # -- common ---------------------------------------------------------------
    ("homebrew", "common", "system"): f"{_M}.homebrew",
    # -- debian ---------------------------------------------------------------
    ("docker", "debian", "system"): f"{_M}.debian_docker",
    ("r", "debian", "system"): f"{_M}.debian_r",
    ("rstudio-server", "debian", "system"): f"{_M}.debian_rstudio_server",
    ("wine", "debian", "system"): f"{_M}.debian_wine",
    # -- fedora ---------------------------------------------------------------
    ("oracle-instant-client", "fedora", "system"): f"{_M}.fedora_oracle_instant_client",
    ("rstudio-server", "fedora", "system"): f"{_M}.fedora_rstudio_server",
    ("shiny-server", "fedora", "system"): f"{_M}.fedora_shiny_server",
    ("wine", "fedora", "system"): f"{_M}.fedora_wine",
    # -- linux ----------------------------------------------------------------
    ("lmod", "linux", "shared"): f"{_M}.linux_lmod",
    ("pihole", "linux", "system"): f"{_M}.linux_pihole",
    ("shiny-server", "linux", "system"): f"{_M}.linux_shiny_server",
    # -- macos ----------------------------------------------------------------
    ("adobe-creative-cloud", "macos", "system"): f"{_M}.macos_adobe_creative_cloud",
    ("cisco-webex", "macos", "system"): f"{_M}.macos_cisco_webex",
    ("docker", "macos", "system"): f"{_M}.macos_docker",
    ("microsoft-onedrive", "macos", "system"): f"{_M}.macos_microsoft_onedrive",
    ("oracle-java", "macos", "system"): f"{_M}.macos_oracle_java",
    ("python", "macos", "system"): f"{_M}.macos_python",
    ("r-gfortran", "macos", "system"): f"{_M}.macos_r_gfortran",
    ("r-xcode-openmp", "macos", "system"): f"{_M}.macos_r_xcode_openmp",
    ("r", "macos", "system"): f"{_M}.macos_r",
    ("ringcentral", "macos", "system"): f"{_M}.macos_ringcentral",
    ("xcode-clt", "macos", "system"): f"{_M}.macos_xcode_clt",
}


def has_python_uninstaller(name: str, platform: str, mode: str) -> bool:
    """Check if app has a Python-native uninstaller."""
    return (name, platform, mode) in PYTHON_UNINSTALLERS


def get_python_uninstaller(
    name: str,
    platform: str,
    mode: str,
) -> Callable[..., None]:
    """Dynamically import and return the uninstaller's ``main`` function."""
    module_path = PYTHON_UNINSTALLERS[(name, platform, mode)]
    mod = importlib.import_module(module_path)
    return mod.main  # type: ignore[attr-defined]
