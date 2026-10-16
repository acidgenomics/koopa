"""Tests for the koopa plugin push gate (plugins/koopa/hooks/push_gate.py).

The gate is opt-in: it does nothing until the repository's `koopa-push-gate` directory under
`.git` exists. Then an agent's `git push` is blocked unless every commit it sends has a
receipt file named by its full SHA.

Safety: every repository is a scratch one under ``tmp_path``. The hook runs as a subprocess with
``CLAUDE_PROJECT_DIR`` pointing at the scratch repository and never pushes anything; it only
reads git state.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

sys.dont_write_bytecode = True

_HOOK = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks" / "push_gate.py"


def _git(repo: Path, *args: str) -> str:
    """Run git in a scratch repository with the user's global hooks disabled."""
    result = subprocess.run(
        [
            "git",
            "-c",
            "user.email=test@example.com",
            "-c",
            "user.name=Test",
            "-c",
            "core.hooksPath=/dev/null",
            *args,
        ],
        cwd=repo,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def _repo(path: Path) -> Path:
    """A scratch repository with one commit on `main` and a `feature` branch."""
    path.mkdir(parents=True)
    _git(path, "init", "-q", "-b", "main")
    (path / "readme.md").write_text("hello\n")
    _git(path, "add", "readme.md")
    _git(path, "commit", "-q", "-m", "init")
    _git(path, "branch", "feature")
    (path / "readme.md").write_text("hello again\n")
    _git(path, "commit", "-q", "-am", "second")
    return path


def _opt_in(repo: Path) -> Path:
    """Create the receipt directory, which opts the repository in."""
    gate = repo / ".git" / "koopa-push-gate"
    gate.mkdir()
    return gate


def _receipt(repo: Path, rev: str) -> None:
    """Record a passing check for *rev*."""
    (repo / ".git" / "koopa-push-gate" / _git(repo, "rev-parse", rev)).touch()


def _run(repo: Path, command: str) -> tuple[int, str]:
    """Run the hook on a Claude Code payload; return ``(exit code, stderr)``."""
    env = {**os.environ, "CLAUDE_PROJECT_DIR": str(repo), "PYTHONDONTWRITEBYTECODE": "1"}
    payload = json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})
    proc = subprocess.run(
        [sys.executable, "-B", str(_HOOK)],
        input=payload,
        capture_output=True,
        text=True,
        check=False,
        env=env,
        cwd=repo,
    )
    return proc.returncode, proc.stderr


@pytest.fixture
def repo(tmp_path: Path) -> Path:
    """A scratch repository that is not yet opted in."""
    return _repo(tmp_path / "repo")


def test_inert_until_opted_in(repo: Path) -> None:
    """With no receipt directory, every push passes."""
    assert _run(repo, "git push origin main")[0] == 0


def test_blocks_push_of_head_without_receipt(repo: Path) -> None:
    """An opted-in repository blocks a push whose commit has no receipt, naming the commit."""
    _opt_in(repo)
    code, err = _run(repo, "git push")
    assert code == 2
    assert _git(repo, "rev-parse", "--short=12", "HEAD") in err


def test_allows_push_with_receipt(repo: Path) -> None:
    """A receipt for HEAD lets the push through."""
    _opt_in(repo)
    _receipt(repo, "HEAD")
    assert _run(repo, "git push -u origin main")[0] == 0


def test_checks_the_refspec_source_not_head(repo: Path) -> None:
    """A refspec's source side is the commit that must have a receipt."""
    _opt_in(repo)
    _receipt(repo, "HEAD")
    code, err = _run(repo, "git push origin feature:feature")
    assert code == 2
    assert "(feature)" in err
    _receipt(repo, "feature")
    assert _run(repo, "git push origin +feature:feature")[0] == 0


def test_deletion_sends_nothing(repo: Path) -> None:
    """A `:dst` refspec deletes a remote branch and is not checked."""
    _opt_in(repo)
    assert _run(repo, "git push origin :old-branch")[0] == 0


def test_push_in_a_different_repo_is_not_checked(repo: Path, tmp_path: Path) -> None:
    """A push run with `git -C` in another repository is outside this project's gate."""
    _opt_in(repo)
    other = _repo(tmp_path / "other")
    assert _run(repo, f"git -C {other} push origin main")[0] == 0


@pytest.mark.parametrize(
    "command",
    [
        "git status",
        'git commit -m "then git push"',
        "echo 'git push origin main'",
    ],
)
def test_ignores_commands_that_do_not_push(repo: Path, command: str) -> None:
    """Only a command that runs `git push` is checked."""
    _opt_in(repo)
    assert _run(repo, command)[0] == 0


def test_fails_open_outside_a_repository(tmp_path: Path) -> None:
    """When git cannot answer, the push passes."""
    plain = tmp_path / "plain"
    plain.mkdir()
    assert _run(plain, "git push")[0] == 0
