"""Refresh the koopa agent plugin for Claude Code and Copilot CLI.

The dotfiles trees declare the plugin and its marketplace in each CLI's
settings file (``enabledPlugins`` and ``extraKnownMarketplaces``). This module
never writes those settings: a CLI install would drift from the chezmoi
source. It only refreshes a plugin that is already declared. Backs the plugin
step of ``koopa update``.
"""

import json
import shutil
import subprocess

_MARKETPLACE = "koopa"
_PLUGIN = "koopa@koopa"


def _run(argv: list[str], *, verbose: bool) -> str:
    """Run one agent CLI command and return its standard output.

    Parameters
    ----------
    argv : list[str]
        Command and arguments.
    verbose : bool
        If True, print the captured output.

    Returns
    -------
    str
        Captured standard output.
    """
    from koopa.alert import alert_detail

    result = subprocess.run(argv, check=True, capture_output=True, text=True)
    if verbose:
        alert_detail((result.stdout or "") + (result.stderr or ""))
    return result.stdout or ""


def _update_claude_plugin(*, verbose: bool) -> bool:
    """Refresh the koopa plugin in Claude Code.

    Parameters
    ----------
    verbose : bool
        If True, print command output.

    Returns
    -------
    bool
        False if the plugin is not installed, so nothing was refreshed.
    """
    plugins = json.loads(_run(["claude", "plugin", "list", "--json"], verbose=False))
    if _PLUGIN not in {p.get("id") for p in plugins}:
        return False
    _run(["claude", "plugin", "marketplace", "update", _MARKETPLACE], verbose=verbose)
    _run(["claude", "plugin", "update", _PLUGIN, "--scope", "user", "--yes"], verbose=verbose)
    return True


def _update_copilot_plugin(*, verbose: bool) -> bool:
    """Refresh the koopa plugin in Copilot CLI.

    Copilot CLI has no JSON output, so this matches the plain-text listing.

    Parameters
    ----------
    verbose : bool
        If True, print command output.

    Returns
    -------
    bool
        False if the plugin is not installed, so nothing was refreshed.
    """
    if _PLUGIN not in _run(["copilot", "plugin", "list"], verbose=False):
        return False
    _run(["copilot", "plugin", "update", _PLUGIN], verbose=verbose)
    return True


def update_agent_plugins(*, verbose: bool = False) -> None:
    """Refresh the koopa plugin for each agent CLI on PATH.

    A CLI that does not have the plugin gets a note to apply the dotfiles. A
    failure in one CLI prints a warning and never stops ``koopa update``.

    Parameters
    ----------
    verbose : bool, optional
        If True, print the output of each CLI command.
    """
    from koopa.alert import alert, alert_note, warn

    steps = (
        ("claude", "Claude Code", _update_claude_plugin),
        ("copilot", "Copilot CLI", _update_copilot_plugin),
    )
    for binary, label, update in steps:
        if shutil.which(binary) is None:
            continue
        alert(f"Updating koopa plugin for {label}.")
        try:
            refreshed = update(verbose=verbose)
        except (subprocess.CalledProcessError, OSError, ValueError) as exc:
            detail = getattr(exc, "stderr", None) or exc
            warn(f"Failed to update koopa plugin for {label}: {detail}")
            continue
        if not refreshed:
            alert_note(
                f"The koopa plugin is not installed in {label}. Apply the dotfiles to declare it."
            )
