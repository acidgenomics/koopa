#!/usr/bin/env python3
"""SessionStart and Stop hook: catch a configured keyword in `.claude/settings.json`.

CLAUDE CODE ONLY. It is registered under `SessionStart` and `Stop` in `hooks/hooks.json`
and deliberately absent from the Copilot registry:

- The gap it closes is Claude Code's own permission-rule writer. When you approve a
  "don't ask again" prompt with project settings as the target, Claude Code writes the new
  rule itself. That write is not a tool call, so no `PreToolUse` hook (`guard_keywords.py`
  included) ever sees it. This hook re-checks the file on session start and on every stop.
  Copilot has no such writer.
- On `Stop` it exits 2 to keep the session going, and relies on the `stop_hook_active` flag
  to avoid a loop. A harness that does not send that flag could loop.

Self-gating. Codex reads the same `hooks/hooks.json`, so the script gates itself: it does
nothing (exit 0, no output) unless `CLAUDE_PROJECT_DIR` is set and non-empty. Claude Code
sets that variable for its hooks and names the project root with it. The variable is also the
only source of the project directory here. Whether Codex leaves it unset is unverified (see
the plugin README).

It reads the same git config keys as `guard_keywords.py` (`koopa.keywords`,
`koopa.contentKeywords`, `koopa.allowedRemotes`, plus the deprecated aliases) and is inert
when no keyword is configured. It scans `$CLAUDE_PROJECT_DIR/.claude/settings.json` line by
line with the same boundary rule (a match must not touch an ASCII letter or digit) and does
nothing unless the file sits in a publishable repository: inside a git work tree, `origin`
not allowlisted, file not gitignored. The message names line numbers and the fix, never the
keyword.

- `SessionStart`: prints `hookSpecificOutput` with `additionalContext` and exits 0.
- `Stop`: prints the message on stderr and exits 2, unless `stop_hook_active` is true.

Fails open: no input, missing file, no git, no config and any error exit 0.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` and `guard_keywords.py`
beside it, and Python 3.10 or newer.
"""

import json
import os
import sys

from guard_keywords import (
    _CONTENT_KEY,
    _OLD_CONTENT_KEY,
    _OLD_PATH_KEY,
    _PATH_KEY,
    _compile,
    _is_publishable,
    _merged_values,
    _valid,
)
from hook_adapter import load_payload


def _hit_lines(text: str) -> list[int]:
    """Return the 1-based numbers of lines that hold a configured keyword."""
    path_values = _merged_values(_PATH_KEY, _OLD_PATH_KEY)
    content_values = _merged_values(_CONTENT_KEY, _OLD_CONTENT_KEY)
    if not path_values and not content_values:
        return []
    path_valid = _valid(path_values, _PATH_KEY)
    matcher = _compile(path_valid + _valid(content_values, _CONTENT_KEY))
    if matcher is None:
        return []
    return [n for n, line in enumerate(text.split("\n"), 1) if matcher.search(line)]


def _message(project_dir: str) -> str | None:
    """Return the warning for a settings file holding a keyword, or None when it is clean."""
    target = os.path.join(project_dir.rstrip("/") or os.sep, ".claude", "settings.json")
    if not os.path.isfile(target):
        return None
    with open(target, encoding="utf-8", errors="replace") as handle:
        text = handle.read()
    lines = _hit_lines(text)
    if not lines or not _is_publishable(target):
        return None
    return (
        f"Configured keyword found in {target} (line(s): {','.join(map(str, lines))}). "
        "Move the offending permission entry to .claude/settings.local.json, "
        "which is gitignored."
    )


def main() -> int:
    """Scan the project's settings file and report a configured keyword."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return 0  # not a Claude Code session: do nothing
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    message = _message(project_dir)
    if message is None:
        return 0
    if payload.get("hook_event_name") != "Stop":
        output = {
            "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": message}
        }
        print(json.dumps(output))
        return 0
    if payload.get("stop_hook_active") in (True, "true"):
        return 0  # already continuing because of this hook: do not loop
    print(message, file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        # Fail open: the git pre-commit hook is the backstop.
        print(
            f"guard_settings_keywords: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
        sys.exit(0)
