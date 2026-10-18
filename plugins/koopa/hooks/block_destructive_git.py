#!/usr/bin/env python3
"""PreToolUse hook: block destructive git commands.

Blocks `reset --hard`, `clean -fd`, force pushes, `git rm -rf`, `checkout -- .`,
`branch -D`, and `push origin main|master`. A push to main or master from a
different repository than the current project (an earlier `cd`, or `git -C`, into
another git root) is allowed. `push --all`, `--branches`, `--mirror`, `:` and glob
refspecs are blocked too, since each can update main without naming it.

It also blocks commands that capture or discard other agent sessions' work in a
shared checkout: `git add -A` / `-u` / `.`, `git commit -a`, a whole-tree `git stash`
and `stash pop|drop|clear`, `git restore .`, `git checkout .`, and
`git worktree remove|prune`. Name the paths instead (`git add -- <file>`,
`git stash push -- <path>`).

This is an opinionated default and a HARD block: no agent-side override. If you
really need the command, run it yourself in the terminal (in Claude Code, type `!`
before the command). A user can switch a rule off for one repository with
`git config --add koopa.allowGitRules "<rule name>"`.

It blocks a command that RUNS one of these, not text that mentions it. The decision
comes from `guard_git_scan.py`, which reads the command the way a shell does. The cd
target is parsed as text and never evaluated. When the parser cannot decide, the
original text patterns decide instead, and `push origin main|master` blocks with no
cd exemption.

Input is a Claude Code `tool_input.command` payload or a Copilot CLI `toolCalls[]`
batch. Empty or malformed stdin passes (exit 0). A block prints the reason to stderr
and exits 2.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import re
import sys

from guard_git_scan import find_destructive
from hook_adapter import load_payload, read_commands

ALWAYS_BLOCKED = (
    "reset --hard",
    "clean -fd",
    "push --force",
    "push -f ",
    "git rm -rf",
    "checkout -- .",
    "branch -D",
    "add -A",
    "commit -a",
    "stash pop",
    "stash drop",
    "stash clear",
    "worktree remove",
    "worktree prune",
)

_PUSH_PROTECTED = re.compile(r"push origin (main|master)\b")


def fallback_rule(command: str) -> str | None:
    """Name the first text pattern that matches, with no cd exemption."""
    for pattern in ALWAYS_BLOCKED:
        if pattern in command:
            return pattern
    if _PUSH_PROTECTED.search(command):
        return "push origin main/master"
    return None


def blocked_rule(command: str) -> str | None:
    """Return the rule *command* triggers, using the text patterns if the parser fails."""
    try:
        return find_destructive(command)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return fallback_rule(command)


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    rule = blocked_rule("\n".join(read_commands(payload)))
    if rule is None:
        return 0
    reason = (
        f"Destructive git command blocked: {rule}. If you really need it, run it yourself "
        "in the terminal (in Claude Code, type ! before the command)."
    )
    sys.stderr.write(json.dumps({"decision": "block", "reason": reason}) + "\n")
    return 2


if __name__ == "__main__":
    sys.exit(main())
