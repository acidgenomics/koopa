#!/usr/bin/env python3
"""PreCompact and SessionStart hook: carry a checkout's git state across a context compaction.

CLAUDE CODE ONLY. Registered under `PreCompact` and `SessionStart` in `hooks/hooks.json` and
deliberately absent from the Copilot registry, which has no compaction event. Self-gating:
it does nothing unless `CLAUDE_PROJECT_DIR` is set, so Codex reading the same file is unaffected.

A compaction replaces the conversation with a summary, and the model cannot see that it
happened. The summary can drop exact facts the next turn depends on, such as which branch is
checked out or which files were left modified.

On `PreCompact` the hook writes what is objectively true and cheap to read: the time, the
project directory, the branch, HEAD and its subject, the last five commits, and
`git status --short` (capped). The file is per session,
`$XDG_STATE_HOME/koopa/compact/<session_id>.md` (`~/.local/state` when unset), so two sessions in
one checkout never read each other's snapshot. It prints nothing. Snapshots older than 14 days
are pruned on each write.

On `SessionStart` with source `compact` it prints, on stdout (which Claude Code adds to the
session context): that a compaction happened, the snapshot's age, and the snapshot, or a line
saying none was found. Any other source prints nothing.

Never blocks: every path exits 0, and every git call is bounded by a timeout.
"""

import hashlib
import os
import re
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

from hook_adapter import load_payload

_TIMEOUT = 4
_MAX_STATUS_LINES = 40
_PRUNE_AFTER_SECONDS = 14 * 24 * 3600
_SAFE_ID = re.compile(r"^[A-Za-z0-9_-]{1,128}$")


def state_dir() -> Path:
    """Return the directory that holds the snapshots."""
    base = os.environ.get("XDG_STATE_HOME") or str(Path.home() / ".local" / "state")
    return Path(base) / "koopa" / "compact"


def snapshot_path(session_id: object, project_dir: str) -> Path:
    """Return the snapshot file for one session, keyed by a filename-safe id."""
    if isinstance(session_id, str) and _SAFE_ID.match(session_id):
        key = session_id
    else:
        key = hashlib.sha256(project_dir.encode()).hexdigest()[:16]
    return state_dir() / f"{key}.md"


def _git(repo: str, *args: str) -> str:
    """Run git in *repo*; return stripped stdout, or a short note when git fails."""
    try:
        result = subprocess.run(
            ["git", "-C", repo, *args],
            capture_output=True,
            text=True,
            check=False,
            timeout=_TIMEOUT,
        )
    except (OSError, subprocess.SubprocessError) as error:
        return f"(git unavailable: {type(error).__name__})"
    if result.returncode != 0:
        return "(not available)"
    return result.stdout.strip()


def build_snapshot(project_dir: str) -> str:
    """Return the Markdown snapshot of *project_dir*'s git state."""
    status = _git(project_dir, "status", "--short").splitlines()
    if len(status) > _MAX_STATUS_LINES:
        extra = len(status) - _MAX_STATUS_LINES
        status = [*status[:_MAX_STATUS_LINES], f"... and {extra} more"]
    lines = [
        f"- Taken: {datetime.now().astimezone().isoformat(timespec='seconds')}",
        f"- Project: {project_dir}",
        f"- Branch: {_git(project_dir, 'branch', '--show-current') or '(detached HEAD)'}",
        f"- HEAD: {_git(project_dir, 'log', '-1', '--format=%h %s')}",
        "",
        "Recent commits:",
        "",
        *(f"    {line}" for line in _git(project_dir, "log", "-5", "--format=%h %s").splitlines()),
        "",
        "Working tree (`git status --short`):",
        "",
        *(f"    {line}" for line in status or ["(clean)"]),
    ]
    return "\n".join(lines) + "\n"


def _prune(directory: Path) -> None:
    """Delete snapshot files in *directory* older than the retention window."""
    cutoff = time.time() - _PRUNE_AFTER_SECONDS
    for path in directory.glob("*.md"):
        if path.stat().st_mtime < cutoff:
            path.unlink()


def write_snapshot(path: Path, project_dir: str) -> None:
    """Write the snapshot for *project_dir* to *path*, pruning stale ones first."""
    path.parent.mkdir(parents=True, exist_ok=True)
    _prune(path.parent)
    path.write_text(build_snapshot(project_dir), encoding="utf-8")


def notice(path: Path) -> str:
    """Return the post-compaction notice for the snapshot at *path*."""
    head = (
        "The conversation was just compacted into a summary. Re-check facts the summary may "
        "have dropped against the checkout itself before acting on them."
    )
    if not path.is_file():
        return f"{head}\nNo pre-compaction git snapshot was found for this session.\n"
    age = int((time.time() - path.stat().st_mtime) / 60)
    body = path.read_text(encoding="utf-8")
    return f"{head}\nGit snapshot taken {age} minute(s) before this notice:\n\n{body}"


def main() -> None:
    """Read the hook payload and write or report the snapshot."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    payload = load_payload(sys.stdin.read())
    if not project_dir or payload is None:
        return
    path = snapshot_path(payload.get("session_id"), project_dir)
    event = payload.get("hook_event_name")
    if event == "PreCompact":
        write_snapshot(path, project_dir)
    elif event == "SessionStart" and payload.get("source") == "compact":
        sys.stdout.write(notice(path))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(
            f"session_compact_snapshot: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
    sys.exit(0)
