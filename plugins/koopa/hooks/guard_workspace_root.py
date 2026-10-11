#!/usr/bin/env python3
"""SessionStart hook: warn (never block) when the session root is not inside a git repo.

CLAUDE CODE ONLY. It is registered under `SessionStart` in `hooks/hooks.json` and
deliberately absent from the Copilot registry. It guards a Claude Code failure mode: a
session started outside a repository never loads the project's `.mcp.json` and
`.claude/settings.json`, so project-scoped MCP tools silently never register. It also takes
the session root from `CLAUDE_PROJECT_DIR`, which Copilot does not set.

Self-gating. Codex reads the same `hooks/hooks.json`, so the script does nothing (exit 0, no
output) unless `CLAUDE_PROJECT_DIR` is set and non-empty. That variable is the session root.
It is used instead of the payload `cwd`, which is the session's current directory and drifts
after any `cd` out of the repository.

The test is "is this inside any git repo", not "is this one named repo", so a git worktree
passes. An editor opened with no workspace folder usually starts in the home directory,
which is not a repository, and that is the state this warns about.

When the root is not inside a repo, the hook prints one plain-text warning line on stdout
(Claude Code adds `SessionStart` stdout to the session context) and exits 0. Set
`CLAUDE_ALLOW_NONREPO_ROOT=1` to allow a deliberate non-repo scratch session.

Fails open: no JSON payload, git missing or timing out, and any error exit 0 with no output.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` beside it, and Python 3.10
or newer.
"""

import os
import subprocess
import sys

from hook_adapter import load_payload

_TIMEOUT = 5


def _inside_repo(root: str) -> bool | None:
    """True or False when git answers, None when git is missing or times out."""
    try:
        subprocess.run(
            ["git", "-C", root, "rev-parse", "--show-toplevel"],
            capture_output=True,
            check=True,
            timeout=_TIMEOUT,
        )
    except subprocess.CalledProcessError:
        return False
    except (subprocess.TimeoutExpired, OSError):
        return None
    return True


def main() -> int:
    """Warn when the Claude Code session root is outside any git repository."""
    root = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not root:
        return 0  # not a Claude Code session: do nothing
    if os.environ.get("CLAUDE_ALLOW_NONREPO_ROOT") == "1":
        return 0
    if load_payload(sys.stdin.read()) is None:
        return 0
    if _inside_repo(root) is not False:
        return 0
    print(
        f"WORKSPACE ROOT: session is not rooted inside a git repo ({root}). Any project-scoped "
        "MCP tools (.mcp.json, .claude/settings.json) will NOT register. Quit the editor and "
        "reopen it with the intended repo as the workspace folder. To allow a deliberate "
        "non-repo session, set CLAUDE_ALLOW_NONREPO_ROOT=1."
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        print(
            f"guard_workspace_root: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
        sys.exit(0)
