"""Shared helper: resolve the active Obsidian vault directory, if any.

No single vault path can be assumed: it varies by machine and person. Four-tier
resolution, in priority order:

1. `KOOPA_BUCKET` env var: koopa's "dated notes bucket" (`_koopa_activate_today_bucket`),
   exported on every koopa shell activation once it resolves a bucket directory.
2. `OBSIDIAN_VAULT_DIR` env var: a narrower, Obsidian-specific override for anyone
   whose koopa bucket is not the vault they want, or who does not use koopa.
3. Auto-detect from Obsidian's own vault registry
   (`~/Library/Application Support/obsidian/obsidian.json` on macOS,
   `~/.config/obsidian/obsidian.json` on Linux): the desktop app's
   `{vault_id: {path, ts, open}}` map. Prefers the vault marked `"open": true`,
   else the most recently used vault (highest `"ts"`).
4. `None`: no vault detected. Callers must fall back to a safe project-local
   default and never assume a vault exists.

Stdlib only: hooks run standalone via `python3 ~/.agents/hooks/X.py`.

This module never writes to Obsidian's own config. The app rewrites that file on
every vault open and close, so a tool must not manage or change it.

Ships in the koopa plugin under `hooks/`, beside its caller `guard_report_path.py`.
Needs Python 3.10 or newer (annotations use `X | None`).
"""

import json
import os

_KOOPA_BUCKET_ENV_VAR = "KOOPA_BUCKET"
_ENV_VAR = "OBSIDIAN_VAULT_DIR"

# Checked in order; the first candidate whose file parses to a non-empty
# `vaults` map wins. macOS first; Linux included for portability at negligible cost.
_CONFIG_CANDIDATES = (
    "~/Library/Application Support/obsidian/obsidian.json",
    "~/.config/obsidian/obsidian.json",
)


def resolve_vault_dir() -> str | None:
    """Return the active Obsidian vault's directory, or None if undetected.

    Returns
    -------
    str | None
        An absolute directory path, or None when no vault could be
        resolved by any tier (no env override, no readable config, or no
        vaults registered in it).
    """
    bucket = os.environ.get(_KOOPA_BUCKET_ENV_VAR)
    if bucket:
        return bucket
    override = os.environ.get(_ENV_VAR)
    if override:
        return override
    return _detect_from_config()


def _detect_from_config() -> str | None:
    """Try each candidate config path in order; return the first hit."""
    for candidate in _CONFIG_CANDIDATES:
        vault_path = _read_vault_path(os.path.expanduser(candidate))
        if vault_path is not None:
            return vault_path
    return None


def _read_vault_path(config_path: str) -> str | None:
    """Parse one `obsidian.json`-shaped file and pick its active vault.

    Parameters
    ----------
    config_path : str
        Absolute path to a candidate `obsidian.json` file.

    Returns
    -------
    str | None
        The chosen vault's `path`, or None if the file is missing,
        unreadable, malformed, or has no usable `vaults` entries.
    """
    try:
        with open(config_path, encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, ValueError):
        return None
    vaults = data.get("vaults")
    if not isinstance(vaults, dict) or not vaults:
        return None
    entries = [v for v in vaults.values() if isinstance(v, dict)]
    if not entries:
        return None
    chosen = next((v for v in entries if v.get("open") is True), None)
    if chosen is None:
        chosen = max(entries, key=lambda v: v.get("ts") or 0)
    path = chosen.get("path")
    return path if isinstance(path, str) and path else None
