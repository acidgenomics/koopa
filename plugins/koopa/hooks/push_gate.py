#!/usr/bin/env python3
"""PreToolUse hook: refuse an agent's `git push` until the project's check passed on that commit.

Opt-in per repository, and inert everywhere else. A repository opts in when its own check
command writes a receipt after a clean, passing run: an empty file named by the full commit
SHA in git's `koopa-push-gate` directory (`git rev-parse --git-path koopa-push-gate`, which
lives inside `.git`, so it is never committed and each worktree shares it). Until that
directory exists the hook does nothing.

For each `git push` the command line runs in the project's own repository (decided by
`guard_git_scan.project_pushes`, which reads the command the way a shell does), the hook
resolves the commit each refspec sends: the source side of `src:dst`, with a leading `+`
dropped, or `HEAD` when no refspec is named or the push uses `--all`, `--branches`,
`--mirror` or `--tags`. A deletion (`:dst`) sends nothing and is not checked. When any sent
commit has no receipt, the push is blocked and the message names the commit.

A receipt says the check passed on that exact commit, so a check script should write it only
when the working tree has no uncommitted changes to tracked files, for example:

    if git diff --quiet HEAD; then
        gate="$(git rev-parse --git-path koopa-push-gate)"
        mkdir -p "$gate" && touch "$gate/$(git rev-parse HEAD)"
    fi

The repository is `CLAUDE_PROJECT_DIR`, else the payload's `cwd`, else the current
directory. Fails open: a git error, an unparseable command, or any internal error exits 0,
because this is a quality gate, not a security boundary, and a bug here must not lock every
Bash call. The user's own pushes from a terminal are never seen.

Input is a Claude Code `tool_input.command` payload or a Copilot CLI `toolCalls[]` batch.
A block prints the reason to stderr and exits 2.
"""

import json
import os
import subprocess
import sys

from guard_git_scan import project_pushes
from hook_adapter import load_payload, read_commands

_WHOLE_PUSH_FLAGS = frozenset({"--all", "--branches", "--mirror", "--tags"})
# `git push` options that take a separate value, so it is not read as the remote.
_PUSH_VALUE_OPTS = frozenset({"-o", "--push-option", "--repo", "--receive-pack", "--exec"})


def _git(repo: str, *args: str) -> str | None:
    """Run git in *repo*; return stripped stdout, or None when git fails."""
    try:
        result = subprocess.run(
            ["git", "-C", repo, *args], capture_output=True, text=True, check=False, timeout=4
        )
    except (OSError, subprocess.SubprocessError):
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def sources(args: list[str]) -> list[str]:
    """Return the revisions a `git push` with *args* sends, defaulting to HEAD."""
    positional: list[str] = []
    skip = False
    for arg in args:
        if skip:
            skip = False
        elif arg in _PUSH_VALUE_OPTS:
            skip = True
        elif not arg.startswith("-"):
            positional.append(arg)
    refspecs = positional[1:]
    if not refspecs or _WHOLE_PUSH_FLAGS.intersection(args):
        return ["HEAD"]
    revs = []
    for refspec in refspecs:
        src = refspec.lstrip("+").split(":", 1)[0]
        if src:
            revs.append(src)
    return revs


def missing_receipts(repo: str, pushes: list[list[str]]) -> list[str]:
    """Return `<sha12> (<rev>)` for every sent commit with no receipt; [] when not opted in."""
    gate = _git(repo, "rev-parse", "--git-path", "koopa-push-gate")
    if not gate:
        return []
    gate_dir = gate if os.path.isabs(gate) else os.path.join(repo, gate)
    if not os.path.isdir(gate_dir):
        return []
    missing = []
    for args in pushes:
        for rev in sources(args):
            sha = _git(repo, "rev-parse", "--verify", "--quiet", f"{rev}^{{commit}}")
            if sha and not os.path.exists(os.path.join(gate_dir, sha)):
                missing.append(f"{sha[:12]} ({rev})")
    return missing


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    cwd = payload.get("cwd")
    repo = os.environ.get("CLAUDE_PROJECT_DIR") or (cwd if isinstance(cwd, str) else "") or "."
    pushes = [args for c in read_commands(payload) for args in project_pushes(c, repo)]
    if not pushes:
        return 0
    missing = missing_receipts(repo, pushes)
    if not missing:
        return 0
    reason = (
        "This repository requires its check to pass on a commit before an agent pushes it, "
        f"and there is no receipt for: {', '.join(missing)}. Run the project's check on a "
        "clean working tree (it records the receipt when it passes), then push."
    )
    sys.stderr.write(json.dumps({"decision": "block", "reason": reason}) + "\n")
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        name = type(error).__name__
        print(f"push_gate: skipped after an internal error ({name})", file=sys.stderr)
        sys.exit(0)
