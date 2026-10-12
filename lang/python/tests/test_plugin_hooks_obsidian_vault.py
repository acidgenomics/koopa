"""Tests for the koopa plugin Obsidian vault resolver (plugins/koopa/hooks/obsidian_vault.py).

Covers every branch of the four-tier resolution: `KOOPA_BUCKET`, the narrower env
override, each config-file outcome, and the "nothing detected" fallback.
"""

import importlib
import json
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True

_HOOKS_DIR = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
sys.path.insert(0, str(_HOOKS_DIR))

obsidian_vault = importlib.import_module("obsidian_vault")
_read_vault_path = obsidian_vault._read_vault_path
resolve_vault_dir = obsidian_vault.resolve_vault_dir

_KOOPA_BUCKET_ENV_VAR = "KOOPA_BUCKET"
_ENV_VAR = "OBSIDIAN_VAULT_DIR"


@pytest.fixture(autouse=True)
def _clear_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Every test starts with no override and no real config candidates."""
    monkeypatch.delenv(_KOOPA_BUCKET_ENV_VAR, raising=False)
    monkeypatch.delenv(_ENV_VAR, raising=False)
    monkeypatch.setattr(obsidian_vault, "_CONFIG_CANDIDATES", ())


def _write_config(path: Path, vaults: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({"vaults": vaults}), encoding="utf-8")


# ── resolve_vault_dir: KOOPA_BUCKET wins over everything ────────────────


def test_koopa_bucket_wins_over_obsidian_env_and_config(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Koopa's own bucket dir wins even if both other tiers also resolve."""
    config = tmp_path / "obsidian.json"
    _write_config(config, {"a": {"path": "/from/config", "ts": 1, "open": True}})
    monkeypatch.setattr(obsidian_vault, "_CONFIG_CANDIDATES", (str(config),))
    monkeypatch.setenv(_ENV_VAR, "/from/env")
    monkeypatch.setenv(_KOOPA_BUCKET_ENV_VAR, "/from/koopa")
    assert resolve_vault_dir() == "/from/koopa"


def test_empty_koopa_bucket_falls_through_to_obsidian_env_var(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """KOOPA_BUCKET set to an empty string is treated as unset, not a real value."""
    monkeypatch.setenv(_KOOPA_BUCKET_ENV_VAR, "")
    monkeypatch.setenv(_ENV_VAR, "/from/env")
    assert resolve_vault_dir() == "/from/env"


# ── resolve_vault_dir: the narrower env var wins over auto-detect ───────


def test_env_var_wins_over_config(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """An explicit override always wins, even if a config file also resolves."""
    config = tmp_path / "obsidian.json"
    _write_config(config, {"a": {"path": "/from/config", "ts": 1, "open": True}})
    monkeypatch.setattr(obsidian_vault, "_CONFIG_CANDIDATES", (str(config),))
    monkeypatch.setenv(_ENV_VAR, "/from/env")
    assert resolve_vault_dir() == "/from/env"


def test_empty_env_var_falls_through_to_config(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """An env var set to an empty string is treated as unset, not a real override."""
    config = tmp_path / "obsidian.json"
    _write_config(config, {"a": {"path": "/from/config", "ts": 1, "open": True}})
    monkeypatch.setattr(obsidian_vault, "_CONFIG_CANDIDATES", (str(config),))
    monkeypatch.setenv(_ENV_VAR, "")
    assert resolve_vault_dir() == "/from/config"


# ── resolve_vault_dir: no override, no config ───────────────────────────


def test_no_override_and_no_config_returns_none() -> None:
    """The safe default: nothing detected, caller falls back to reports/."""
    assert resolve_vault_dir() is None


# ── _read_vault_path: vault selection within one config file ───────────


def test_open_vault_wins_over_higher_ts(tmp_path: Path) -> None:
    """A vault marked open: true wins even if another has a higher ts."""
    config = tmp_path / "obsidian.json"
    _write_config(
        config,
        {
            "a": {"path": "/stale-but-open", "ts": 1, "open": True},
            "b": {"path": "/newer-but-closed", "ts": 999, "open": False},
        },
    )
    assert _read_vault_path(str(config)) == "/stale-but-open"


def test_highest_ts_wins_when_none_open(tmp_path: Path) -> None:
    """With no vault marked open, the most recently used one wins."""
    config = tmp_path / "obsidian.json"
    _write_config(
        config,
        {
            "a": {"path": "/older", "ts": 1, "open": False},
            "b": {"path": "/newer", "ts": 999, "open": False},
        },
    )
    assert _read_vault_path(str(config)) == "/newer"


def test_missing_file_returns_none(tmp_path: Path) -> None:
    """A candidate path with no file at all is not an error -- just a miss."""
    assert _read_vault_path(str(tmp_path / "does-not-exist.json")) is None


def test_malformed_json_returns_none(tmp_path: Path) -> None:
    """A config file that fails to parse is not an error -- just a miss."""
    config = tmp_path / "obsidian.json"
    config.write_text("{not valid json", encoding="utf-8")
    assert _read_vault_path(str(config)) is None


def test_empty_vaults_dict_returns_none(tmp_path: Path) -> None:
    """A real config with zero registered vaults resolves to nothing."""
    config = tmp_path / "obsidian.json"
    _write_config(config, {})
    assert _read_vault_path(str(config)) is None


def test_missing_vaults_key_returns_none(tmp_path: Path) -> None:
    """A config file with no `vaults` key at all (e.g. `{"cli": true}`)."""
    config = tmp_path / "obsidian.json"
    config.write_text(json.dumps({"cli": True}), encoding="utf-8")
    assert _read_vault_path(str(config)) is None


def test_vault_entry_missing_path_returns_none(tmp_path: Path) -> None:
    """A vault entry present but with no `path` field never crashes."""
    config = tmp_path / "obsidian.json"
    _write_config(config, {"a": {"ts": 1, "open": True}})
    assert _read_vault_path(str(config)) is None


def test_second_candidate_used_when_first_config_is_absent(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """The macOS/Linux candidate list is tried in order; a miss moves on."""
    missing = tmp_path / "does-not-exist" / "obsidian.json"
    present = tmp_path / "linux" / "obsidian.json"
    _write_config(present, {"a": {"path": "/linux-vault", "ts": 1, "open": True}})
    monkeypatch.setattr(obsidian_vault, "_CONFIG_CANDIDATES", (str(missing), str(present)))
    assert resolve_vault_dir() == "/linux-vault"
