"""Refresh the koopa agent plugin for Claude Code and Copilot CLI.

The dotfiles trees declare the plugin and its marketplace in each CLI's
settings file (``enabledPlugins`` and ``extraKnownMarketplaces``). This module
never writes those settings: a CLI install would drift from the chezmoi
source. It only refreshes a plugin that is already declared. Backs the plugin
step of ``koopa update``.

A refresh runs only for a CLI that has the plugin installed, and only when the
committed plugin files changed since the last refresh of that CLI. The module
records a hash of ``plugins/koopa`` and ``.claude-plugin`` per CLI under the
koopa cache directory, so an update that pulls nothing new prints nothing here.
A CLI without the plugin is skipped silently. The record survives the process
restart that ``koopa update`` does after a Python change.
"""

import json
import os
import shutil
import subprocess

_MARKETPLACE = "koopa"
_PLUGIN = "koopa@koopa"
_PLUGIN_PATHS = ("plugins/koopa", ".claude-plugin")


def _state_path() -> str:
    """Return the path of the file that records the last refreshed plugin hash.

    Returns
    -------
    str
        Path to ``agent-plugin-refresh.json`` in the koopa cache directory.
    """
    from koopa.xdg import xdg_cache_home

    return os.path.join(xdg_cache_home(), "koopa", "agent-plugin-refresh.json")


def _read_state() -> dict[str, str]:
    """Read the recorded plugin hash for each agent CLI.

    Returns
    -------
    dict[str, str]
        Mapping of CLI binary name to the plugin hash at its last refresh. Empty
        if the record is missing or unreadable.
    """
    try:
        with open(_state_path(), encoding="utf-8") as handle:
            data = json.load(handle)
    except (OSError, ValueError):
        return {}
    if not isinstance(data, dict):
        return {}
    return {str(key): str(value) for key, value in data.items()}


def _write_state(state: dict[str, str]) -> None:
    """Record the plugin hash for each agent CLI.

    A failed write only costs one extra refresh on the next update, so it is
    ignored.

    Parameters
    ----------
    state : dict[str, str]
        Mapping of CLI binary name to plugin hash.
    """
    path = _state_path()
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as handle:
            json.dump(state, handle, indent=2)
            handle.write("\n")
    except OSError:
        return


def _plugin_fingerprint() -> str | None:
    """Return a hash of the committed plugin files in the koopa checkout.

    Returns
    -------
    str | None
        Git tree hashes of the plugin paths at ``HEAD``, or None if they cannot
        be read. None makes every update refresh the plugin.
    """
    from koopa.prefix import koopa_prefix

    argv = ["git", "-C", koopa_prefix(), "rev-parse", *(f"HEAD:{p}" for p in _PLUGIN_PATHS)]
    try:
        result = subprocess.run(argv, check=True, capture_output=True, text=True)
    except (subprocess.CalledProcessError, OSError):
        return None
    return ":".join(result.stdout.split()) or None


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


def _claude_has_plugin() -> bool:
    """Report whether Claude Code has the koopa plugin installed.

    Returns
    -------
    bool
        True if ``claude plugin list`` includes the koopa plugin.
    """
    plugins = json.loads(_run(["claude", "plugin", "list", "--json"], verbose=False))
    return _PLUGIN in {p.get("id") for p in plugins}


def _refresh_claude_plugin(*, verbose: bool) -> None:
    """Refresh the koopa plugin in Claude Code.

    Parameters
    ----------
    verbose : bool
        If True, print command output.
    """
    _run(["claude", "plugin", "marketplace", "update", _MARKETPLACE], verbose=verbose)
    _run(["claude", "plugin", "update", _PLUGIN, "--scope", "user", "--yes"], verbose=verbose)


def _copilot_has_plugin() -> bool:
    """Report whether Copilot CLI has the koopa plugin.

    Copilot CLI has no JSON output, so this matches the plain-text listing.

    Returns
    -------
    bool
        True if ``copilot plugin list`` includes the koopa plugin.
    """
    return _PLUGIN in _run(["copilot", "plugin", "list"], verbose=False)


def _refresh_copilot_plugin(*, verbose: bool) -> None:
    """Refresh the koopa plugin in Copilot CLI.

    Parameters
    ----------
    verbose : bool
        If True, print command output.
    """
    _run(["copilot", "plugin", "update", _PLUGIN], verbose=verbose)


def update_agent_plugins(*, verbose: bool = False) -> None:
    """Refresh the koopa plugin for each agent CLI on PATH that has it and is out of date.

    A CLI is skipped, with no output, when it is not on ``PATH``, when it does
    not have the plugin installed (the dotfiles declare the plugin, and a CLI
    that has not picked it up yet is not an error), or when the committed
    plugin files are the same as at its last refresh. Only an actual refresh
    prints a line. A failed refresh prints a warning, is not recorded (so the
    next update tries again), and never stops ``koopa update``.

    Parameters
    ----------
    verbose : bool, optional
        If True, print the output of each CLI command and explain each skip.
    """
    from koopa.alert import alert, alert_detail, warn

    fingerprint = _plugin_fingerprint()
    state = _read_state()
    steps = (
        ("claude", "Claude Code", _claude_has_plugin, _refresh_claude_plugin),
        ("copilot", "Copilot CLI", _copilot_has_plugin, _refresh_copilot_plugin),
    )
    changed = False
    for binary, label, has_plugin, refresh in steps:
        if shutil.which(binary) is None:
            continue
        if fingerprint is not None and state.get(binary) == fingerprint:
            if verbose:
                alert_detail(f"The koopa plugin in {label} is current.")
            continue
        try:
            installed = has_plugin()
        except (subprocess.CalledProcessError, OSError, ValueError):
            installed = False
        if not installed:
            if verbose:
                alert_detail(f"The koopa plugin is not installed in {label}; skipping.")
            continue
        alert(f"Refreshing the koopa plugin in {label}.")
        try:
            refresh(verbose=verbose)
        except (subprocess.CalledProcessError, OSError, ValueError) as exc:
            detail = getattr(exc, "stderr", None) or exc
            warn(f"Failed to refresh the koopa plugin in {label}: {detail}")
            continue
        if fingerprint is not None:
            state[binary] = fingerprint
            changed = True
    if changed:
        _write_state(state)
