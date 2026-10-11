"""Tests for the koopa plugin `reports/` guard (plugins/koopa/hooks/guard_report_path.py).

The hook redirects a `reports/` write to an Obsidian vault only when
`obsidian_vault.resolve_vault_dir()` detects one on the running machine. Direct
`decide()` tests control that branch with `monkeypatch`. Subprocess-level
(`main()`) tests use the real resolution mechanism instead: `OBSIDIAN_VAULT_DIR`
in the subprocess `env` for "vault detected", or a `HOME` pointed at an empty
directory for "no vault detected".

Safety: every write target is a string given to the decision functions; nothing is written.
"""

import importlib
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True

_HOOKS_DIR = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
sys.path.insert(0, str(_HOOKS_DIR))

guard_report_path = importlib.import_module("guard_report_path")
decide = guard_report_path.decide

_HOOK_PATH = _HOOKS_DIR / "guard_report_path.py"
_VAULT = "/home/user/vault"


def _detect_vault(monkeypatch: pytest.MonkeyPatch) -> None:
    """Force `decide()` to see `_VAULT` as the detected vault."""
    monkeypatch.setattr(guard_report_path, "resolve_vault_dir", lambda: _VAULT)


def _detect_no_vault(monkeypatch: pytest.MonkeyPatch) -> None:
    """Force `decide()` to see no vault -- the safe default for most machines."""
    monkeypatch.setattr(guard_report_path, "resolve_vault_dir", lambda: None)


def _run_main(
    stdin: str, env_overrides: dict[str, str] | None = None, home: Path | None = None
) -> subprocess.CompletedProcess[str]:
    """Invoke `main()` in a real subprocess with a controlled environment."""
    env = dict(os.environ)
    # KOOPA_BUCKET now outranks OBSIDIAN_VAULT_DIR (see obsidian_vault.py) --
    # clear both here so a real koopa-activated dev machine can't shadow
    # whichever tier a given test means to exercise.
    env.pop("KOOPA_BUCKET", None)
    env.pop("OBSIDIAN_VAULT_DIR", None)
    if home is not None:
        env["HOME"] = str(home)
    if env_overrides:
        env.update(env_overrides)
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_HOOK_PATH)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


# ── decide(): a vault is detected -- redirect ───────────────────────────


def test_nested_shape_is_denied_when_vault_detected(monkeypatch: pytest.MonkeyPatch) -> None:
    """A write into the nested 'reports/YYYY/MM/DD/' shape redirects to the vault."""
    _detect_vault(monkeypatch)
    reason = decide("reports/2026/09/02/x.md")
    assert reason is not None
    assert f"{_VAULT}/2026/09/02/x.md" in reason


def test_flat_shape_is_denied_when_vault_detected(monkeypatch: pytest.MonkeyPatch) -> None:
    """A write into the old flat 'reports/YYYY-MM-DD/' shape redirects too."""
    _detect_vault(monkeypatch)
    reason = decide("reports/2026-09-02/x.md")
    assert reason is not None
    assert f"{_VAULT}/2026/09/02/x.md" in reason


def test_non_dated_reports_path_gets_generic_suggestion_when_vault_detected(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A `reports/` write with no derivable date still redirects, generic suggestion."""
    _detect_vault(monkeypatch)
    reason = decide("reports/x.md")
    assert reason is not None
    assert f"{_VAULT}/YYYY/MM/DD/<slug>.md" in reason


# ── decide(): no vault detected -- allow the reports/ fallback ─────────


def test_reports_write_is_allowed_when_no_vault_detected(monkeypatch: pytest.MonkeyPatch) -> None:
    """The safe default: no vault on this machine, so reports/ is a real destination."""
    _detect_no_vault(monkeypatch)
    assert decide("reports/2026/09/02/x.md") is None


# ── decide(): scope guards, independent of vault detection ─────────────


def test_scripts_path_is_not_scoped_by_this_guard(monkeypatch: pytest.MonkeyPatch) -> None:
    """A dated `scripts/` path is untouched -- this guard only covers reports/."""
    _detect_vault(monkeypatch)
    assert decide("scripts/2026-09-02/x.py") is None


def test_vault_path_is_untouched(monkeypatch: pytest.MonkeyPatch) -> None:
    """A write to the vault itself (outside this repo) is never in scope."""
    _detect_vault(monkeypatch)
    assert decide(f"{_VAULT}/2026/09/18/x.md") is None


def test_empty_path_is_allowed(monkeypatch: pytest.MonkeyPatch) -> None:
    """No file_path (e.g. a tool with no path field) never blocks."""
    _detect_vault(monkeypatch)
    assert decide("") is None


# ── main(): subprocess-level, controlled via the real resolution mechanism ──


def test_empty_stdin_exits_zero() -> None:
    """The hook's main() must fail open on empty stdin, never block a tool call."""
    result = _run_main("")
    assert result.returncode == 0


def test_malformed_json_stdin_exits_zero() -> None:
    """The hook's main() must fail open on malformed JSON, never block a tool call."""
    result = _run_main("{not valid json")
    assert result.returncode == 0


def test_reports_write_via_stdin_exits_two_when_vault_env_set() -> None:
    """End-to-end: an OBSIDIAN_VAULT_DIR override redirects a real reports/ write."""
    payload = '{"tool_input": {"file_path": "reports/2026/09/02/x.md"}}'
    result = _run_main(payload, env_overrides={"OBSIDIAN_VAULT_DIR": _VAULT})
    assert result.returncode == 2
    assert f"{_VAULT}/2026/09/02/x.md" in result.stderr


def test_reports_write_via_stdin_exits_zero_when_no_vault(tmp_path: Path) -> None:
    """End-to-end: with no override and no real obsidian.json under HOME, allow it."""
    payload = '{"tool_input": {"file_path": "reports/2026/09/02/x.md"}}'
    result = _run_main(payload, home=tmp_path)
    assert result.returncode == 0


# ── H8: delete/move-source targets must not be blocked ────────────────────


def test_deleting_a_reports_file_is_allowed() -> None:
    """Removing a file already sitting in reports/ must not be blocked.

    Negative control for the pre-fix code: `main()` used to call `decide()`
    on every target regardless of verb, so cleaning up a stale `reports/`
    file was denied by the very guard meant to discourage that shape.
    """
    patch = "\n".join(
        ["*** Begin Patch", "*** Delete File: reports/2026/09/02/x.md", "*** End Patch"]
    )
    payload = json.dumps({"tool_input": patch})
    result = _run_main(payload, env_overrides={"OBSIDIAN_VAULT_DIR": _VAULT})
    assert result.returncode == 0


def test_moving_out_of_reports_is_allowed() -> None:
    """The source side of a migrating move (out of reports/) must not be blocked."""
    patch = "\n".join(
        [
            "*** Begin Patch",
            "*** Update File: reports/2026/09/02/x.md",
            "*** Move to: scratch/x.md",
            "+content",
            "*** End Patch",
        ]
    )
    payload = json.dumps({"tool_input": patch})
    result = _run_main(payload, env_overrides={"OBSIDIAN_VAULT_DIR": _VAULT})
    assert result.returncode == 0


def test_moving_into_reports_is_still_denied_when_vault_detected() -> None:
    """A move's destination side is a genuine new write -- still checked."""
    patch = "\n".join(
        [
            "*** Begin Patch",
            "*** Update File: scratch/x.md",
            "*** Move to: reports/2026/09/02/x.md",
            "+content",
            "*** End Patch",
        ]
    )
    payload = json.dumps({"tool_input": patch})
    result = _run_main(payload, env_overrides={"OBSIDIAN_VAULT_DIR": _VAULT})
    assert result.returncode == 2
    assert f"{_VAULT}/2026/09/02/x.md" in result.stderr


# ── scope: only dated folders and the project's top-level reports/ ─────────


def test_source_package_named_reports_is_allowed(monkeypatch: pytest.MonkeyPatch) -> None:
    """A real `src/reports/` module is never a session report, even with a vault."""
    _detect_vault(monkeypatch)
    assert decide("src/reports/builder.py") is None
    assert decide("/work/proj/app/reports/views.py") is None


def test_dated_folder_under_nested_reports_is_denied(monkeypatch: pytest.MonkeyPatch) -> None:
    """A dated folder is a session report wherever its `reports/` parent sits."""
    _detect_vault(monkeypatch)
    assert decide("/work/proj/reports/2026/09/02/x.md") is not None


def test_absolute_top_level_reports_is_denied(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """An absolute path directly under the project's `reports/` is in scope."""
    _detect_vault(monkeypatch)
    monkeypatch.setenv("CLAUDE_PROJECT_DIR", str(tmp_path))
    assert decide(str(tmp_path / "reports" / "x.md")) is not None


def test_absolute_nested_reports_without_date_is_allowed(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """An undated `reports/` folder below the project root is not top-level."""
    _detect_vault(monkeypatch)
    monkeypatch.setenv("CLAUDE_PROJECT_DIR", str(tmp_path))
    assert decide(str(tmp_path / "app" / "reports" / "x.md")) is None
