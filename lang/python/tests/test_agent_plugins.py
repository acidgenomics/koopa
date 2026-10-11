"""Tests for the agent plugin refresh step of ``koopa update``."""

import json
import subprocess

import pytest
from koopa import agent_plugins


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


def _setup(monkeypatch: pytest.MonkeyPatch, runner: _Runner, binaries: tuple[str, ...]) -> None:
    monkeypatch.setattr(
        agent_plugins.shutil, "which", lambda b: f"/bin/{b}" if b in binaries else None
    )
    monkeypatch.setattr(agent_plugins.subprocess, "run", runner)


def test_no_cli_on_path_runs_nothing(monkeypatch: pytest.MonkeyPatch) -> None:
    """No agent CLI on PATH means no subprocess call."""
    runner = _Runner({})
    _setup(monkeypatch, runner, ())
    agent_plugins.update_agent_plugins()
    assert runner.calls == []


def test_claude_installed_is_refreshed(monkeypatch: pytest.MonkeyPatch) -> None:
    """An installed plugin gets a marketplace refresh and a plugin update."""
    runner = _Runner({("claude", "plugin", "list", "--json"): json.dumps([{"id": "koopa@koopa"}])})
    _setup(monkeypatch, runner, ("claude",))
    agent_plugins.update_agent_plugins()
    assert ("claude", "plugin", "marketplace", "update", "koopa") in runner.calls
    assert ("claude", "plugin", "update", "koopa@koopa", "--scope", "user", "--yes") in runner.calls


def test_claude_missing_is_not_installed(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A missing plugin is never installed from here: the dotfiles declare it."""
    runner = _Runner({("claude", "plugin", "list", "--json"): "[]"})
    _setup(monkeypatch, runner, ("claude",))
    agent_plugins.update_agent_plugins()
    assert runner.calls == [("claude", "plugin", "list", "--json")]
    assert "not installed in Claude Code" in capsys.readouterr().err


def test_copilot_installed_is_refreshed(monkeypatch: pytest.MonkeyPatch) -> None:
    """An installed Copilot plugin is updated."""
    runner = _Runner({("copilot", "plugin", "list"): "koopa@koopa (v0.34.0) (enabled)"})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    assert ("copilot", "plugin", "update", "koopa@koopa") in runner.calls


def test_copilot_missing_is_not_installed(monkeypatch: pytest.MonkeyPatch) -> None:
    """A missing Copilot plugin is never installed or enabled from here."""
    runner = _Runner({("copilot", "plugin", "list"): "No plugins installed."})
    _setup(monkeypatch, runner, ("copilot",))
    agent_plugins.update_agent_plugins()
    assert runner.calls == [("copilot", "plugin", "list")]


def test_failure_warns_and_does_not_raise(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A failing CLI call prints a warning and does not stop the update."""
    runner = _Runner({}, fail=True)
    _setup(monkeypatch, runner, ("claude", "copilot"))
    agent_plugins.update_agent_plugins()
    err = capsys.readouterr().err
    assert "Claude Code" in err
    assert "Copilot CLI" in err
