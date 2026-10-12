#!/usr/bin/env python3
"""PreToolUse hook: scan the outgoing commit range for secret-shaped filenames.

Runs only for a real `git push`, decided by `guard_git_scan.py`, which reads the
command the way a shell does. When the parser cannot decide, a text pattern decides.
It lists every file touched by every commit in the outgoing range (`@{u}..HEAD`,
falling back to `origin/<branch>..HEAD`) and blocks when a secret-shaped filename
appears. The staged index is not what `git push` sends, so it is not scanned.

The repository is the one named by `CLAUDE_PROJECT_DIR`, else the payload's `cwd`
field, else the current directory. A git failure (not a repository, no range) never
blocks: the hook exits 0.

Input is a Claude Code `tool_input.command` payload or a Copilot CLI `toolCalls[]`
batch. Empty or malformed stdin passes (exit 0). A block prints the findings and the
reason to stderr and exits 2.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import os
import re
import subprocess
import sys

from guard_git_scan import runs_git_push
from hook_adapter import load_payload, read_commands

_PUSH_FALLBACK = re.compile(r"(^|[^A-Za-z0-9_./-])git[\s]+push([\s]|$)")
_SECRET_NAME = re.compile(r"\.(env|pem|p12)$|credentials\.json|secrets\.|_key\.")
_REASON = (
    "Potential secrets detected in the outgoing commit range. "
    "Review and remove sensitive files from history before pushing."
)


def is_push(command: str) -> bool:
    """Say whether *command* runs `git push`, using a text pattern if the parser fails."""
    try:
        return runs_git_push(command)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return _PUSH_FALLBACK.search(command) is not None


def _git(repo: str, *args: str) -> str:
    """Run git in *repo* and return stdout; raises CalledProcessError or OSError."""
    result = subprocess.run(
        ["git", *args], cwd=repo, capture_output=True, text=True, check=True, timeout=4
    )
    return result.stdout.strip()


def outgoing_range(repo: str) -> str:
    """Return `@{u}..HEAD`, else `origin/<branch>..HEAD`."""
    try:
        upstream = _git(repo, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}")
    except subprocess.CalledProcessError:
        upstream = ""
    if upstream:
        return f"{upstream}..HEAD"
    return f"origin/{_git(repo, 'rev-parse', '--abbrev-ref', 'HEAD')}..HEAD"


def suspicious_files(repo: str) -> tuple[str, list[str]]:
    """Return the outgoing range and the secret-shaped files in it.

    Raises CalledProcessError or OSError when git cannot answer.
    """
    rng = outgoing_range(repo)
    names = _git(repo, "log", "--name-only", "--pretty=format:", rng).splitlines()
    return rng, sorted({n for n in names if _SECRET_NAME.search(n)})


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    if not is_push("\n".join(read_commands(payload))):
        return 0
    cwd = payload.get("cwd")
    repo = os.environ.get("CLAUDE_PROJECT_DIR") or (cwd if isinstance(cwd, str) else "") or "."
    try:
        rng, found = suspicious_files(repo)
    except (subprocess.SubprocessError, OSError):
        return 0
    if not found:
        return 0
    sys.stderr.write(f"BLOCKED: Potential secrets in the outgoing commit range ({rng}):\n")
    sys.stderr.write("\n".join(found) + "\n")
    sys.stderr.write('{"decision":"block","reason":"' + _REASON + '"}\n')
    return 2


if __name__ == "__main__":
    sys.exit(main())
