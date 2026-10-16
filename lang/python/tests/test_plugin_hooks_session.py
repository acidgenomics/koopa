"""Tests for the koopa plugin session hooks (compaction snapshot and local time zone).

Both hooks are Claude Code only, never block, and do nothing unless ``CLAUDE_PROJECT_DIR`` is
set. Snapshots are written under an ``XDG_STATE_HOME`` inside ``tmp_path``, never the real
state directory, and git only reads scratch repositories under ``tmp_path``.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

sys.dont_write_bytecode = True

_HOOKS = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
_SNAPSHOT = _HOOKS / "session_compact_snapshot.py"
_LOCAL_TIME = _HOOKS / "session_local_time.py"


def _run(hook: Path, payload: object, env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    """Run a hook entry with *payload* on stdin."""
    return subprocess.run(
        [sys.executable, "-B", str(hook)],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        check=False,
        env=env,
    )


@pytest.fixture
def project(tmp_path: Path) -> Path:
    """A scratch repository with one commit and one modified file."""
    repo = tmp_path / "repo"
    repo.mkdir()
    git = [
        "git",
        "-c",
        "user.email=t@example.com",
        "-c",
        "user.name=T",
        "-c",
        "core.hooksPath=/dev/null",
    ]
    subprocess.run([*git, "init", "-q"], cwd=repo, check=True)
    (repo / "readme.md").write_text("one\n")
    subprocess.run([*git, "add", "-f", "readme.md"], cwd=repo, check=True)
    subprocess.run([*git, "commit", "-q", "-m", "first commit"], cwd=repo, check=True)
    # A git template can make `init -b` a no-op, so name the branch after the first commit.
    subprocess.run([*git, "checkout", "-q", "-b", "work"], cwd=repo, check=True)
    (repo / "readme.md").write_text("two\n")
    return repo


@pytest.fixture
def env(tmp_path: Path, project: Path) -> dict[str, str]:
    """An environment with an isolated state directory and the project set."""
    return {
        **os.environ,
        "CLAUDE_PROJECT_DIR": str(project),
        "XDG_STATE_HOME": str(tmp_path / "state"),
        "PYTHONDONTWRITEBYTECODE": "1",
    }


def _event(name: str, **extra: str) -> dict[str, str]:
    return {"hook_event_name": name, "session_id": "abc-123", **extra}


def test_precompact_writes_a_snapshot_and_prints_nothing(
    tmp_path: Path, env: dict[str, str]
) -> None:
    """PreCompact records the branch, HEAD and working tree for this session."""
    result = _run(_SNAPSHOT, _event("PreCompact", trigger="auto"), env)
    assert result.returncode == 0
    assert result.stdout == ""
    text = (tmp_path / "state" / "koopa" / "compact" / "abc-123.md").read_text()
    assert "Branch: work" in text
    assert "first commit" in text
    assert "M readme.md" in text


def test_compact_start_reports_the_snapshot(env: dict[str, str]) -> None:
    """After a compaction, SessionStart prints the notice and the snapshot."""
    _run(_SNAPSHOT, _event("PreCompact"), env)
    result = _run(_SNAPSHOT, _event("SessionStart", source="compact"), env)
    assert result.returncode == 0
    assert "just compacted" in result.stdout
    assert "Branch: work" in result.stdout


def test_compact_start_without_snapshot_says_so(env: dict[str, str]) -> None:
    """A missing snapshot is reported, never silently skipped."""
    result = _run(_SNAPSHOT, _event("SessionStart", source="compact"), env)
    assert "No pre-compaction git snapshot" in result.stdout


@pytest.mark.parametrize("source", ["startup", "resume", "clear"])
def test_other_session_starts_print_nothing(env: dict[str, str], source: str) -> None:
    """Only a compaction earns a notice."""
    _run(_SNAPSHOT, _event("PreCompact"), env)
    assert _run(_SNAPSHOT, _event("SessionStart", source=source), env).stdout == ""


def test_unsafe_session_id_never_names_a_path(tmp_path: Path, env: dict[str, str]) -> None:
    """A session id with path characters is replaced by a hash, never used as a filename."""
    payload = {"hook_event_name": "PreCompact", "session_id": "../../escape"}
    assert _run(_SNAPSHOT, payload, env).returncode == 0
    written = list((tmp_path / "state" / "koopa" / "compact").glob("*.md"))
    assert len(written) == 1
    assert ".." not in written[0].name
    assert not (tmp_path / "escape.md").exists()


def test_snapshot_needs_claude_project_dir(tmp_path: Path, env: dict[str, str]) -> None:
    """Without CLAUDE_PROJECT_DIR the hook writes nothing."""
    env = {k: v for k, v in env.items() if k != "CLAUDE_PROJECT_DIR"}
    assert _run(_SNAPSHOT, _event("PreCompact"), env).returncode == 0
    assert not (tmp_path / "state").exists()


def test_local_time_names_the_tz_zone(env: dict[str, str]) -> None:
    """`TZ` wins, and the line states the offset."""
    result = _run(_LOCAL_TIME, {"hook_event_name": "SessionStart"}, {**env, "TZ": "Asia/Tokyo"})
    assert result.returncode == 0
    assert "Asia/Tokyo (UTC+09:00" in result.stdout


def test_local_time_needs_claude_project_dir(env: dict[str, str]) -> None:
    """Without CLAUDE_PROJECT_DIR the hook prints nothing."""
    env = {k: v for k, v in env.items() if k != "CLAUDE_PROJECT_DIR"}
    assert _run(_LOCAL_TIME, {"hook_event_name": "SessionStart"}, env).stdout == ""
