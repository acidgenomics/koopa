"""Tests for koopa app claude subcommands."""

from pathlib import Path

import pytest
from koopa.cli_app import _PYTHON_HANDLERS, _estimate_claude_tokens, _rule_is_path_scoped


def test_claude_audit_tokens_registered() -> None:
    """Test that claude-audit-tokens is registered in _PYTHON_HANDLERS."""
    assert "claude-audit-tokens" in _PYTHON_HANDLERS
    assert callable(_PYTHON_HANDLERS["claude-audit-tokens"])


def test_estimate_claude_tokens_empty() -> None:
    """Empty string yields 0 tokens."""
    assert _estimate_claude_tokens("") == 0


def test_estimate_claude_tokens_heuristic() -> None:
    """100 chars yields 25 tokens (chars // 4)."""
    assert _estimate_claude_tokens("x" * 100) == 25


def test_claude_audit_tokens_help(capsys: pytest.CaptureFixture[str]) -> None:
    """--help exits cleanly and mentions max-tokens."""
    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS["claude-audit-tokens"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "max-tokens" in captured.out.lower()


def test_claude_audit_tokens_reports_files(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Reports token counts for CLAUDE.md and rules/*.md under a synthetic home."""
    claude_dir = tmp_path / ".claude"
    rules_dir = claude_dir / "rules"
    rules_dir.mkdir(parents=True)
    (claude_dir / "CLAUDE.md").write_text("a" * 400)
    (rules_dir / "workflow.md").write_text("b" * 800)

    monkeypatch.setenv("HOME", str(tmp_path))

    _PYTHON_HANDLERS["claude-audit-tokens"]([])
    captured = capsys.readouterr()
    assert "CLAUDE.md" in captured.out
    assert "workflow.md" in captured.out
    # total: 1200 chars -> 300 tokens
    assert "300" in captured.out


def test_claude_audit_tokens_max_tokens_pass(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Exits 0 when total tokens are within --max-tokens."""
    claude_dir = tmp_path / ".claude"
    claude_dir.mkdir()
    (claude_dir / "CLAUDE.md").write_text("a" * 400)  # 100 tokens

    monkeypatch.setenv("HOME", str(tmp_path))

    _PYTHON_HANDLERS["claude-audit-tokens"](["--max-tokens", "200"])
    # no SystemExit raised


def test_claude_audit_tokens_max_tokens_fail(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Exits 1 when total tokens exceed --max-tokens."""
    claude_dir = tmp_path / ".claude"
    claude_dir.mkdir()
    (claude_dir / "CLAUDE.md").write_text("a" * 400)  # 100 tokens

    monkeypatch.setenv("HOME", str(tmp_path))

    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS["claude-audit-tokens"](["--max-tokens", "1"])
    assert exc_info.value.code == 1


def test_claude_audit_tokens_no_files(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Handles missing ~/.claude gracefully."""
    monkeypatch.setenv("HOME", str(tmp_path))
    _PYTHON_HANDLERS["claude-audit-tokens"]([])
    # no crash; stderr note about no files
    captured = capsys.readouterr()
    assert captured.out == ""


def test_rule_is_path_scoped() -> None:
    """Rules with paths: frontmatter are detected; others are not."""
    scoped = "---\npaths:\n  - '**/*.py'\n---\n\n# content"
    not_scoped_plain = "# content"
    not_scoped_no_paths = "---\nname: foo\n---\n\n# content"
    assert _rule_is_path_scoped(scoped) is True
    assert _rule_is_path_scoped(not_scoped_plain) is False
    assert _rule_is_path_scoped(not_scoped_no_paths) is False


def test_claude_audit_tokens_path_scoped_excluded_from_always_loaded(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Path-scoped rules appear under conditional section, not always-loaded total."""
    claude_dir = tmp_path / ".claude"
    rules_dir = claude_dir / "rules"
    rules_dir.mkdir(parents=True)
    (claude_dir / "CLAUDE.md").write_text("a" * 400)  # 100 tokens always-loaded
    # Path-scoped rule: large but conditional — must NOT count toward always-loaded
    scoped_content = "---\npaths:\n  - '**/*.py'\n---\n" + "b" * 4000  # 1000 tokens
    (rules_dir / "python.md").write_text(scoped_content)

    monkeypatch.setenv("HOME", str(tmp_path))

    # --max-tokens 200 should PASS: only 100 always-loaded tokens (CLAUDE.md),
    # not 1100 (which would exceed it).
    _PYTHON_HANDLERS["claude-audit-tokens"](["--max-tokens", "200"])

    captured = capsys.readouterr()
    assert "Always-loaded" in captured.out
    assert "Path-scoped" in captured.out
    # always-loaded total: 100 tokens
    assert "100" in captured.out
    # python.md listed under conditional section
    assert "python.md" in captured.out
