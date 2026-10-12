"""Tests for the agent plugin refresh step of ``koopa update``."""

import json
import subprocess
from pathlib import Path

import pytest
from koopa import agent_plugins

_CLAUDE_LIST = ("claude", "plugin", "list", "--json")
_CLAUDE_MARKETPLACE = ("claude", "plugin", "marketplace", "update", "koopa")
_CLAUDE_UPDATE = ("claude", "plugin", "update", "koopa@koopa", "--scope", "user", "--yes")
_COPILOT_LIST = ("copilot", "plugin", "list")
_COPILOT_UPDATE = ("copilot", "plugin", "update", "koopa@koopa")
_INSTALLED_CLAUDE = json.dumps([{"id": "koopa@koopa"}])
_INSTALLED_COPILOT = "koopa@koopa (v0.34.0) (enabled)"


class _Runner:
    """Record argv and return canned standard output for each command."""

    def __init__(self, outputs: dict[tuple[str, ...], str], fail: bool = False) -> None:
        self.outputs = outputs
        self.fail = fail
        self.calls: list[tuple[str, ...]] = []

    def __call__(self, argv: list[str], **_: object) -> subprocess.CompletedProcess[str]:
        key = tuple(argv)
        self.calls.append(key)
        if self.fail:
            raise subprocess.CalledProcessError(1, argv, stderr="boom")
        return subprocess.CompletedProcess(argv, 0, stdout=self.outputs.get(key, ""), stderr="")


class _Env:
    """Handles for the fingerprint and the state file used by one test."""

    def __init__(self, state_path: Path) -> None:
        self.fingerprint: str | None = "hash-1"
        self.state_path = state_path


@pytest.fixture
def env(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> _Env:
    """Isolate the state file and the plugin fingerprint from the real machine."""
    handle = _Env(tmp_path / "agent-plugin-refresh.json")
    monkeypatch.setattr(agent_plugins, "_state_path", lambda: str(handle.state_path))
    monkeypatch.setattr(agent_plugins, "_plugin_fingerprint", lambda: handle.fingerprint)
    return handle


def _setup(monkeypatch: pytest.MonkeyPatch, runner: _Runner, binaries: tuple[str, ...]) -> None:
    monkeypatch.setattr(
        agent_plugins.shutil, "which", lambda b: f"/bin/{b}" if b in binaries else None
    )
    monkeypatch.setattr(agent_plugins.subprocess, "run", runner)


def _state(handle: _Env) -> dict[str, str]:
    return json.loads(handle.state_path.read_text(encoding="utf-8"))


def test_no_cli_on_path_runs_nothing(monkeypatch: pytest.MonkeyPatch, env: _Env) -> None:
    """No agent CLI on PATH means no subprocess call and no record."""
    runner = _Runner({})
    _setup(monkeypatch, runner, ())
    agent_plugins.update_agent_plugins()
    assert runner.calls == []
    assert not env.state_path.exists()


def test_claude_installed_is_refreshed(monkeypatch: pytest.MonkeyPatch, env: _Env) -> None:
    """An installed plugin gets a marketplace refresh and a plugin update."""
    runner = _Runner({_CLAUDE_LIST: _INSTALLED_CLAUDE})
    _setup(monkeypatch, runner, ("claude",))
    agent_plugins.update_agent_plugins()
    assert _CLAUDE_MARKETPLACE in runner.calls
    assert _CLAUDE_UPDATE in runner.calls
    assert _state(env) == {"claude": "hash-1"}


def test_claude_missing_is_skipped_silently(
    monkeypatch: pytest.MonkeyPatch, env: _Env, capsys: pytest.CaptureFixture[str]
) -> None:
    """A missing plugin is never installed from here and prints nothing."""
    runner = _Runner({_CLAUDE_LIST: "[]"})
    _setup(monkeypatch, runner, ("claude",))
    agent_plugins.update_agent_plugins()
    captured = capsys.readouterr()
    assert runner.calls == [_CLAUDE_LIST]
    assert captured.out == ""
    assert captured.err == ""
    assert not env.state_path.exists()


def test_copilot_installed_is_refreshed(monkeypatch: pytest.MonkeyPatch, env: _Env) -> None:
    """An installed Copilot plugin is updated."""
    runner = _Runner({_COPILOT_LIST: _INSTALLED_COPILOT})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    assert _COPILOT_UPDATE in runner.calls
    assert _state(env) == {"copilot": "hash-1"}


def test_copilot_missing_is_skipped_silently(
    monkeypatch: pytest.MonkeyPatch, env: _Env, capsys: pytest.CaptureFixture[str]
) -> None:
    """A missing Copilot plugin is never installed or enabled from here."""
    runner = _Runner({_COPILOT_LIST: "No plugins installed."})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    captured = capsys.readouterr()
    assert runner.calls == [_COPILOT_LIST]
    assert captured.out == ""
    assert captured.err == ""


def test_second_update_with_same_plugin_files_does_nothing(
    monkeypatch: pytest.MonkeyPatch, env: _Env, capsys: pytest.CaptureFixture[str]
) -> None:
    """After a refresh, an update that pulls no plugin change makes no CLI call at all."""
    first = _Runner({_CLAUDE_LIST: _INSTALLED_CLAUDE, _COPILOT_LIST: _INSTALLED_COPILOT})
    _setup(monkeypatch, first, ("claude", "copilot"))
    agent_plugins.update_agent_plugins()
    capsys.readouterr()
    second = _Runner({})
    _setup(monkeypatch, second, ("claude", "copilot"))
    agent_plugins.update_agent_plugins()
    captured = capsys.readouterr()
    assert second.calls == []
    assert captured.out == ""
    assert captured.err == ""


def test_changed_plugin_files_refresh_again(monkeypatch: pytest.MonkeyPatch, env: _Env) -> None:
    """A new plugin hash triggers a new refresh and a new record."""
    runner = _Runner({_COPILOT_LIST: _INSTALLED_COPILOT})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    env.fingerprint = "hash-2"
    runner.calls.clear()
    agent_plugins.update_agent_plugins()
    assert _COPILOT_UPDATE in runner.calls
    assert _state(env) == {"copilot": "hash-2"}


def test_plugin_installed_later_is_refreshed_on_next_update(
    monkeypatch: pytest.MonkeyPatch, env: _Env
) -> None:
    """A skipped CLI is not recorded, so installing the plugin later triggers one refresh."""
    missing = _Runner({_CLAUDE_LIST: "[]"})
    _setup(monkeypatch, missing, ("claude",))
    agent_plugins.update_agent_plugins()
    installed = _Runner({_CLAUDE_LIST: _INSTALLED_CLAUDE})
    _setup(monkeypatch, installed, ("claude",))
    agent_plugins.update_agent_plugins()
    assert _CLAUDE_UPDATE in installed.calls


def test_unknown_plugin_hash_always_refreshes(monkeypatch: pytest.MonkeyPatch, env: _Env) -> None:
    """If git cannot say what the plugin files are, every update refreshes."""
    env.fingerprint = None
    runner = _Runner({_COPILOT_LIST: _INSTALLED_COPILOT})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    agent_plugins.update_agent_plugins()
    assert runner.calls.count(_COPILOT_UPDATE) == 2
    assert not env.state_path.exists()


def test_failed_refresh_warns_and_is_retried_next_time(
    monkeypatch: pytest.MonkeyPatch, env: _Env, capsys: pytest.CaptureFixture[str]
) -> None:
    """A failing refresh prints a warning, does not raise, and is not recorded."""

    class _FailOnUpdate(_Runner):
        def __call__(self, argv: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
            if tuple(argv) == _COPILOT_UPDATE:
                self.calls.append(tuple(argv))
                raise subprocess.CalledProcessError(1, argv, stderr="boom")
            return super().__call__(argv, **kwargs)

    runner = _FailOnUpdate({_COPILOT_LIST: _INSTALLED_COPILOT})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    err = capsys.readouterr().err
    assert "Copilot CLI" in err
    assert "boom" in err
    assert not env.state_path.exists()


def test_failed_listing_is_skipped_silently(
    monkeypatch: pytest.MonkeyPatch, env: _Env, capsys: pytest.CaptureFixture[str]
) -> None:
    """A CLI that cannot even list plugins is treated as not set up, with no output."""
    runner = _Runner({}, fail=True)
    _setup(monkeypatch, runner, ("claude", "copilot"))
    agent_plugins.update_agent_plugins()
    captured = capsys.readouterr()
    assert captured.out == ""
    assert captured.err == ""


def test_unreadable_state_file_is_ignored(monkeypatch: pytest.MonkeyPatch, env: _Env) -> None:
    """A corrupt record only costs one extra refresh."""
    env.state_path.write_text("not json", encoding="utf-8")
    runner = _Runner({_COPILOT_LIST: _INSTALLED_COPILOT})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    assert _COPILOT_UPDATE in runner.calls
    assert _state(env) == {"copilot": "hash-1"}
