"""Tests for switching koopa's Git-managed branch."""

import subprocess
from pathlib import Path

import pytest
from koopa import cli_develop, cli_system


def _git(path: Path, *args: str) -> str:
    result = subprocess.run(["git", *args], cwd=path, capture_output=True, text=True, check=True)
    return result.stdout.strip()


@pytest.fixture
def checkout(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    """Create an isolated develop-only shallow clone with a separate main."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setenv("GIT_CONFIG_GLOBAL", str(tmp_path / "gitconfig"))
    monkeypatch.setenv("GIT_CONFIG_NOSYSTEM", "1")
    monkeypatch.setenv("GIT_TERMINAL_PROMPT", "0")
    monkeypatch.setenv("GIT_AUTHOR_NAME", "Test")
    monkeypatch.setenv("GIT_AUTHOR_EMAIL", "test@example.invalid")
    monkeypatch.setenv("GIT_COMMITTER_NAME", "Test")
    monkeypatch.setenv("GIT_COMMITTER_EMAIL", "test@example.invalid")
    source = tmp_path / "source"
    source.mkdir()
    _git(source, "init", "-b", "main")
    (source / "tracked").write_text("main")
    _git(source, "add", "tracked")
    _git(source, "-c", "commit.gpgSign=false", "commit", "-m", "main")
    _git(source, "switch", "-c", "develop")
    (source / "tracked").write_text("develop")
    _git(source, "add", "tracked")
    _git(source, "-c", "commit.gpgSign=false", "commit", "-m", "develop")
    target = tmp_path / "checkout"
    _git(
        tmp_path,
        "clone",
        "--depth=1",
        "--single-branch",
        "-b",
        "develop",
        source.as_uri(),
        str(target),
    )
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(target))
    monkeypatch.setattr("koopa.install._zsh_compaudit_set_permissions", lambda: None)
    return target


def test_switches_shallow_clone_between_branches(checkout: Path) -> None:
    """Fetch main for a single-branch clone and reuse existing branches."""
    (checkout / "local-data").write_text("keep")
    cli_develop.handle_develop(["switch-to-main"])
    assert _git(checkout, "branch", "--show-current") == "main"
    assert (checkout / "tracked").read_text() == "main"
    assert _git(checkout, "rev-parse", "--abbrev-ref", "@{upstream}") == "origin/main"
    assert (checkout / "local-data").read_text() == "keep"

    cli_develop.handle_develop(["switch-to-develop"])
    assert _git(checkout, "branch", "--show-current") == "develop"
    cli_develop.handle_develop(["switch-to-main"])
    assert _git(checkout, "branch", "--show-current") == "main"


def test_refuses_tracked_changes_without_switching(checkout: Path) -> None:
    """Do not carry tracked modifications onto the other branch."""
    (checkout / "tracked").write_text("local edits")
    before = _git(checkout, "config", "--get-all", "remote.origin.fetch")
    with pytest.raises(RuntimeError, match="Tracked files have local changes"):
        cli_develop.handle_develop(["switch-to-main"])
    assert _git(checkout, "branch", "--show-current") == "develop"
    assert (checkout / "tracked").read_text() == "local edits"
    assert _git(checkout, "config", "--get-all", "remote.origin.fetch") == before


def test_existing_main_switches_offline_without_reset(checkout: Path) -> None:
    """Keep local main commits and avoid network access when the branch exists."""
    cli_develop.handle_develop(["switch-to-main"])
    (checkout / "tracked").write_text("local main commit")
    _git(checkout, "add", "tracked")
    _git(checkout, "-c", "commit.gpgSign=false", "commit", "-m", "local main")
    local_commit = _git(checkout, "rev-parse", "HEAD")
    cli_develop.handle_develop(["switch-to-develop"])
    _git(checkout, "remote", "set-url", "origin", "/nonexistent/koopa-repository")
    cli_develop.handle_develop(["switch-to-main"])
    assert _git(checkout, "rev-parse", "HEAD") == local_commit
    assert (checkout / "tracked").read_text() == "local main commit"


def test_refuses_non_git_installation(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """A stable archive cannot be switched to a Git branch."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))
    with pytest.raises(RuntimeError, match="Not a Git-managed"):
        cli_develop.handle_develop(["switch-to-main"])


def test_help_does_not_inspect_or_switch_checkout(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """The help flag must never trigger the guarded operation."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: pytest.fail("unexpected inspection"))
    with pytest.raises(SystemExit) as exc:
        cli_develop.handle_develop(["switch-to-main", "--help"])
    assert exc.value.code == 0
    assert "switch-to-main" in capsys.readouterr().out


def test_legacy_system_alias(checkout: Path) -> None:
    """The existing system command continues to work after moving the commands."""
    cli_develop.handle_develop(["switch-to-main"])
    cli_system.handle_system(["switch-to-develop"])
    assert _git(checkout, "branch", "--show-current") == "develop"
