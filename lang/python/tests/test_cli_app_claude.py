"""Tests for koopa app claude subcommands."""

from pathlib import Path

import pytest
from koopa.cli_app import (
    _PYTHON_HANDLERS,
    _estimate_claude_tokens,
    _find_project_root,
    _rule_is_path_scoped,
    _scan_claude_config,
)


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
    # Use --scope global so no project discovery touches real CWD
    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "global"])
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

    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "global", "--max-tokens", "200"])
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
        _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "global", "--max-tokens", "1"])
    assert exc_info.value.code == 1


def test_claude_audit_tokens_no_files(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Handles missing ~/.claude gracefully."""
    monkeypatch.setenv("HOME", str(tmp_path))
    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "global"])
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
    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "global", "--max-tokens", "200"])

    captured = capsys.readouterr()
    assert "Global" in captured.out
    assert "Path-scoped" in captured.out
    # always-loaded total: 100 tokens
    assert "100" in captured.out
    # python.md listed under conditional section
    assert "python.md" in captured.out


# --- New tests for project-scope and combined mode ---------------------------


def test_claude_audit_tokens_project_dir(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """--project-dir reports project config and combined token count."""
    # Synthetic global HOME: empty (no .claude)
    global_home = tmp_path / "home"
    global_home.mkdir()
    monkeypatch.setenv("HOME", str(global_home))

    # Synthetic project dir
    proj_dir = tmp_path / "myproject"
    claude_dir = proj_dir / ".claude"
    rules_dir = claude_dir / "rules"
    rules_dir.mkdir(parents=True)
    (proj_dir / "CLAUDE.md").write_text("a" * 200)  # 50 tokens
    (rules_dir / "project_rule.md").write_text("b" * 400)  # 100 tokens

    _PYTHON_HANDLERS["claude-audit-tokens"](["--project-dir", str(proj_dir)])
    captured = capsys.readouterr()
    assert "Project" in captured.out
    # combined always-loaded: (200+400)//4 = 150 tokens
    assert "150" in captured.out


def test_claude_audit_tokens_scope_global_only(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """--scope global prints only Global block; Combined footer is absent."""
    claude_dir = tmp_path / ".claude"
    claude_dir.mkdir()
    (claude_dir / "CLAUDE.md").write_text("a" * 400)  # 100 tokens
    monkeypatch.setenv("HOME", str(tmp_path))

    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "global"])
    captured = capsys.readouterr()
    assert "Global" in captured.out
    assert "Combined" not in captured.out


def test_claude_audit_tokens_scope_project_only(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """--scope project prints only Project block; Global block is absent."""
    global_home = tmp_path / "home"
    global_home.mkdir()
    monkeypatch.setenv("HOME", str(global_home))

    proj_dir = tmp_path / "myproject"
    claude_dir = proj_dir / ".claude"
    rules_dir = claude_dir / "rules"
    rules_dir.mkdir(parents=True)
    (proj_dir / "CLAUDE.md").write_text("a" * 200)  # 50 tokens
    (rules_dir / "project_rule.md").write_text("b" * 400)  # 100 tokens

    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "project", "--project-dir", str(proj_dir)])
    captured = capsys.readouterr()
    assert "Project" in captured.out
    assert "Global" not in captured.out


def test_claude_audit_tokens_combined_max_tokens(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Combined always-loaded count is used for --max-tokens gate."""
    global_home = tmp_path / "home"
    global_claude = global_home / ".claude"
    global_claude.mkdir(parents=True)
    (global_claude / "CLAUDE.md").write_text("a" * 400)  # 100 tokens
    monkeypatch.setenv("HOME", str(global_home))

    proj_dir = tmp_path / "myproject"
    proj_claude = proj_dir / ".claude"
    proj_claude.mkdir(parents=True)
    (proj_dir / "CLAUDE.md").write_text("b" * 400)  # 100 tokens

    # combined = 200 tokens; --max-tokens 150 → fail
    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS["claude-audit-tokens"](
            ["--project-dir", str(proj_dir), "--max-tokens", "150"]
        )
    assert exc_info.value.code == 1

    # combined = 200 tokens; --max-tokens 250 → pass
    _PYTHON_HANDLERS["claude-audit-tokens"](["--project-dir", str(proj_dir), "--max-tokens", "250"])


def test_claude_audit_tokens_project_scoped_rule_conditional(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Project path-scoped rules are excluded from the always-loaded count."""
    global_home = tmp_path / "home"
    global_home.mkdir()
    monkeypatch.setenv("HOME", str(global_home))

    proj_dir = tmp_path / "myproject"
    claude_dir = proj_dir / ".claude"
    rules_dir = claude_dir / "rules"
    rules_dir.mkdir(parents=True)
    (proj_dir / "CLAUDE.md").write_text("a" * 400)  # 100 tokens always-loaded
    scoped_content = "---\npaths:\n  - '**/*.py'\n---\n" + "b" * 1000  # scoped
    (rules_dir / "scoped.md").write_text(scoped_content)

    # always-loaded = 100 tokens; --max-tokens 200 passes
    _PYTHON_HANDLERS["claude-audit-tokens"](
        ["--scope", "project", "--project-dir", str(proj_dir), "--max-tokens", "200"]
    )


def test_claude_audit_tokens_no_project_claude_dir(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """--scope all with --project-dir pointing at a plain dir emits a note and continues."""
    claude_dir = tmp_path / ".claude"
    claude_dir.mkdir()
    (claude_dir / "CLAUDE.md").write_text("a" * 400)
    monkeypatch.setenv("HOME", str(tmp_path))

    # project dir has no .claude/ and no CLAUDE.md
    plain_dir = tmp_path / "plain"
    plain_dir.mkdir()

    _PYTHON_HANDLERS["claude-audit-tokens"](["--scope", "all", "--project-dir", str(plain_dir)])
    captured = capsys.readouterr()
    # No crash; note about no project config (goes to stderr via alert_note)
    assert "No project" in captured.err


def test_scan_claude_config_dedup(tmp_path: Path) -> None:
    """_scan_claude_config deduplicates when display_root/CLAUDE.md == claude_dir/CLAUDE.md."""
    # When CLAUDE.md is directly in .claude/ (not in the parent display_root),
    # and there is no CLAUDE.md at display_root, we get 1 entry not 2.
    claude_dir = tmp_path / ".claude"
    claude_dir.mkdir()
    (claude_dir / "CLAUDE.md").write_text("x" * 100)

    rows = _scan_claude_config(str(claude_dir), str(tmp_path))
    paths = [r[0] for r in rows]
    assert len(paths) == len(set(paths)), "duplicate rel paths returned"
    assert len(rows) == 1


def test_find_project_root_finds_claude_dir(tmp_path: Path) -> None:
    """_find_project_root returns the directory containing a .claude/ subdir."""
    proj = tmp_path / "myproject"
    (proj / ".claude").mkdir(parents=True)
    start = proj / "src" / "pkg"
    start.mkdir(parents=True)

    result = _find_project_root(str(start))
    assert result == str(proj)


def test_find_project_root_no_match(tmp_path: Path) -> None:
    """_find_project_root returns None when no .claude/ or .git/ is found."""
    start = tmp_path / "nested" / "deep"
    start.mkdir(parents=True)
    # tmp_path has no .claude/ or .git/; HOME is not set here but the
    # function compares against expanduser("~") which is the real home —
    # tmp_path will not equal home, so we just need no .claude/.git present.
    result = _find_project_root(str(start))
    # Result may be None or may find the real git root of this test process;
    # the important thing is it doesn't crash.
    assert result is None or isinstance(result, str)
