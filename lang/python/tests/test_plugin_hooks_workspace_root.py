"""Tests for the koopa plugin workspace-root guard (plugins/koopa/hooks/guard_workspace_root.py).

The hook is Claude Code only. On `SessionStart` it prints a one-line warning on stdout when
`$CLAUDE_PROJECT_DIR` is not inside any git repository. It never blocks (always exit 0) and does
nothing when `CLAUDE_PROJECT_DIR` is unset.

Safety: git runs only on directories under `tmp_path`, with `GIT_CONFIG_GLOBAL` pointing at a
file under `tmp_path`, `GIT_CONFIG_SYSTEM=/dev/null` and `HOME` under `tmp_path`. A
`GIT_CEILING_DIRECTORIES` entry stops git from finding a repository above `tmp_path`.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

_HOOK = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks" / "guard_workspace_root.py"
_START = json.dumps({"hook_event_name": "SessionStart", "source": "startup"})


def _env(tmp_path: Path, project: Path | None = None, **extra: str) -> dict[str, str]:
    """Build an isolated environment; `project` sets CLAUDE_PROJECT_DIR when given."""
    home = tmp_path / "home"
    home.mkdir(parents=True, exist_ok=True)
    (tmp_path / "gitconfig").write_text("", encoding="utf-8")
    env = {
        k: v
        for k, v in os.environ.items()
        if not k.startswith("GIT_") and k not in ("CLAUDE_PROJECT_DIR", "CLAUDE_ALLOW_NONREPO_ROOT")
    }
    env.update(
        {
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(home / ".config"),
            "GIT_CONFIG_GLOBAL": str(tmp_path / "gitconfig"),
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CEILING_DIRECTORIES": str(tmp_path),
            "PYTHONDONTWRITEBYTECODE": "1",
        }
    )
    if project is not None:
        env["CLAUDE_PROJECT_DIR"] = str(project)
    env.update(extra)
    return env


def _run(stdin: str, env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    """Run the real hook entry; a nonzero exit is returned, not raised."""
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_HOOK)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def _repo(tmp_path: Path, env: dict[str, str]) -> Path:
    """Create a git repository under tmp_path."""
    repo = tmp_path / "repo"
    repo.mkdir()
    subprocess.run(["git", "init", "-q"], cwd=repo, env=env, check=True, capture_output=True)
    return repo


def test_warns_when_the_root_is_not_inside_a_repo(tmp_path: Path) -> None:
    """A plain directory prints one warning on stdout and still exits 0."""
    plain = tmp_path / "plain"
    plain.mkdir()
    result = _run(_START, _env(tmp_path, plain))
    assert result.returncode == 0
    assert result.stderr == ""
    assert result.stdout.startswith("WORKSPACE ROOT:")
    assert result.stdout.count("\n") == 1
    assert str(plain) in result.stdout
    assert "CLAUDE_ALLOW_NONREPO_ROOT=1" in result.stdout


def test_a_missing_directory_is_not_a_repo(tmp_path: Path) -> None:
    """A root that does not exist cannot be a repository, so it warns."""
    result = _run(_START, _env(tmp_path, tmp_path / "gone"))
    assert result.returncode == 0
    assert "WORKSPACE ROOT" in result.stdout


def test_a_repo_root_is_silent(tmp_path: Path) -> None:
    """The top of a repository passes."""
    env = _env(tmp_path)
    env["CLAUDE_PROJECT_DIR"] = str(_repo(tmp_path, env))
    result = _run(_START, env)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_a_subdirectory_of_a_repo_is_silent(tmp_path: Path) -> None:
    """Any directory inside a work tree passes, not only its top."""
    env = _env(tmp_path)
    repo = _repo(tmp_path, env)
    (repo / "src").mkdir()
    env["CLAUDE_PROJECT_DIR"] = str(repo / "src")
    assert _run(_START, env).stdout == ""


def test_a_linked_worktree_is_silent(tmp_path: Path) -> None:
    """A git worktree passes: the test is any repo, not one named repo."""
    env = _env(tmp_path)
    repo = _repo(tmp_path, env)
    git = ["git", "-c", "user.name=jdoe42", "-c", "user.email=jdoe42@example.com"]
    subprocess.run(
        [*git, "commit", "--allow-empty", "-q", "-m", "init"],
        cwd=repo,
        env=env,
        check=True,
        capture_output=True,
    )
    worktree = tmp_path / "linked"
    subprocess.run(
        ["git", "worktree", "add", "-q", str(worktree)],
        cwd=repo,
        env=env,
        check=True,
        capture_output=True,
    )
    env["CLAUDE_PROJECT_DIR"] = str(worktree)
    assert _run(_START, env).stdout == ""


def test_without_claude_project_dir_the_hook_does_nothing(tmp_path: Path) -> None:
    """The self-gate: no CLAUDE_PROJECT_DIR means not a Claude Code session, so no-op."""
    plain = tmp_path / "plain"
    plain.mkdir()
    env = _env(tmp_path)
    result = subprocess.run(
        [sys.executable, "-B", str(_HOOK)],
        input=json.dumps({"hook_event_name": "SessionStart", "cwd": str(plain)}),
        capture_output=True,
        text=True,
        check=True,
        env=env,
        cwd=plain,
    )
    assert (result.stdout, result.stderr) == ("", "")


def test_an_empty_claude_project_dir_counts_as_unset(tmp_path: Path) -> None:
    """An empty variable does not open the gate."""
    result = _run(_START, _env(tmp_path, CLAUDE_PROJECT_DIR=""))
    assert (result.returncode, result.stdout) == (0, "")


def test_escape_hatch_allows_a_non_repo_session(tmp_path: Path) -> None:
    """CLAUDE_ALLOW_NONREPO_ROOT=1 silences the warning."""
    plain = tmp_path / "plain"
    plain.mkdir()
    result = _run(_START, _env(tmp_path, plain, CLAUDE_ALLOW_NONREPO_ROOT="1"))
    assert (result.returncode, result.stdout) == (0, "")


@pytest.mark.parametrize("value", ["", "0", "true", "yes"])
def test_only_the_value_one_is_the_escape_hatch(value: str, tmp_path: Path) -> None:
    """Any other value leaves the warning on."""
    plain = tmp_path / "plain"
    plain.mkdir()
    result = _run(_START, _env(tmp_path, plain, CLAUDE_ALLOW_NONREPO_ROOT=value))
    assert "WORKSPACE ROOT" in result.stdout


def test_the_payload_cwd_is_not_the_root(tmp_path: Path) -> None:
    """A payload cwd outside the repo does not matter: the session root decides."""
    env = _env(tmp_path)
    env["CLAUDE_PROJECT_DIR"] = str(_repo(tmp_path, env))
    outside = tmp_path / "outside"
    outside.mkdir()
    payload = json.dumps({"hook_event_name": "SessionStart", "cwd": str(outside)})
    assert _run(payload, env).stdout == ""


@pytest.mark.parametrize("stdin", ["", "  \n", "not json", "[]", "3"])
def test_empty_or_malformed_stdin_exits_zero(stdin: str, tmp_path: Path) -> None:
    """No JSON object on stdin means no opinion, even with the gate open on a non-repo."""
    plain = tmp_path / "plain"
    plain.mkdir()
    result = _run(stdin, _env(tmp_path, plain))
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_git_missing_fails_open(tmp_path: Path) -> None:
    """With git absent from PATH the hook cannot tell, so it stays silent."""
    plain = tmp_path / "plain"
    plain.mkdir()
    env = _env(tmp_path, plain)
    env["PATH"] = str(tmp_path / "empty-bin")
    result = _run(_START, env)
    assert (result.returncode, result.stdout) == (0, "")


def test_git_timeout_fails_open(tmp_path: Path) -> None:
    """A git call that times out is not evidence of a non-repo, so it stays silent."""
    plain = tmp_path / "plain"
    plain.mkdir()
    runner = tmp_path / "run_hook.py"
    runner.write_text(
        "import runpy, subprocess\n"
        "def slow(*args, **kwargs):\n"
        "    raise subprocess.TimeoutExpired(cmd='git', timeout=5)\n"
        "subprocess.run = slow\n"
        f"runpy.run_path({str(_HOOK)!r}, run_name='__main__')\n",
        encoding="utf-8",
    )
    env = _env(tmp_path, plain)
    env["PYTHONPATH"] = str(_HOOK.parent)
    result = subprocess.run(
        [sys.executable, "-B", str(runner)],
        input=_START,
        capture_output=True,
        text=True,
        check=True,
        env=env,
    )
    assert (result.returncode, result.stdout) == (0, "")


def test_internal_error_fails_open(tmp_path: Path) -> None:
    """An unexpected exception exits 0 with one line on stderr."""
    plain = tmp_path / "plain"
    plain.mkdir()
    runner = tmp_path / "run_hook.py"
    runner.write_text(
        "import runpy\n"
        "import hook_adapter\n"
        "def boom(raw):\n"
        "    raise RuntimeError('x')\n"
        "hook_adapter.load_payload = boom\n"
        f"runpy.run_path({str(_HOOK)!r}, run_name='__main__')\n",
        encoding="utf-8",
    )
    env = _env(tmp_path, plain)
    env["PYTHONPATH"] = str(_HOOK.parent)
    result = subprocess.run(
        [sys.executable, "-B", str(runner)],
        input=_START,
        capture_output=True,
        text=True,
        check=True,
        env=env,
    )
    assert result.returncode == 0
    assert "RuntimeError" in result.stderr
    assert result.stdout == ""
