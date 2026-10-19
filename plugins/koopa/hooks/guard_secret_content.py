#!/usr/bin/env python3
"""PreToolUse hook: block a file write whose new content holds a credential.

Checks the NEW content of every file an agent writes, on any path: Claude Code
`Write`/`Edit`/`MultiEdit`/`NotebookEdit`, Copilot CLI `edit`/`create`, and `apply_patch`
envelopes naming several files (each target is judged on its own). The shared
`hook_adapter.py` reads no `MultiEdit` `edits[].new_string` and no `NotebookEdit`
`new_source`, so this hook reads those two fields itself. It looks for these well-known
credential shapes:

- an AWS access key ID (`AKIA` or `ASIA` plus 16 characters);
- a presigned URL signature (`X-Amz-Signature=` plus 64 hex characters);
- a Databricks personal access token (`dapi` plus 32 hex characters);
- a GitHub token (`ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_`, or `github_pat_`);
- a bearer credential (`Bearer` plus 20 or more token characters);
- a PEM or OpenSSH private key block with key material under its header.

Documented placeholders pass: a match that contains `EXAMPLE` (as AWS's documentation
keys do), or whose value uses fewer than six distinct characters (`ghp_xxxx...`,
`dapi0000...`). Text that only names a shape passes too: a parameter name with no value,
a `Bearer <token>` or `Bearer ${TOKEN}` template, or a private-key header with no key
material below it. Only the new content (`FileTarget.body`) is checked, never the text
being replaced. A delete, or the source side of a move, is never checked.

A block names the kind of credential, the file, and the line within the new content,
never the matched value. It prints the reason on stderr and exits 2. Empty or malformed
stdin exits 0. Fails open on any unexpected error (one line on stderr, exit 0), so a bug
skips the check instead of locking every write.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` beside it, and Python
3.10 or newer (annotations use `X | None`).
"""

import re
import sys

from hook_adapter import HookInputError, load_payload, read_targets

_PLACEHOLDER_WORD = "EXAMPLE"
_MIN_DISTINCT_CHARS = 6

# (kind, pattern). The named group `value` is the part judged for a placeholder.
_SHAPES: tuple[tuple[str, re.Pattern[str]], ...] = (
    (
        "an AWS access key ID",
        re.compile(r"(?<![A-Za-z0-9])(?:AKIA|ASIA)(?P<value>[A-Z0-9]{16})(?![A-Za-z0-9])"),
    ),
    (
        "a presigned URL signature",
        re.compile(r"X-Amz-Signature=(?P<value>[0-9a-f]{64})(?![0-9a-f])", re.IGNORECASE),
    ),
    (
        "a Databricks token",
        re.compile(r"(?<![A-Za-z0-9])dapi(?P<value>[0-9a-f]{32})(?![0-9a-f])"),
    ),
    (
        "a GitHub token",
        re.compile(r"(?<![A-Za-z0-9_])gh[pousr]_(?P<value>[A-Za-z0-9]{36,})"),
    ),
    (
        "a GitHub token",
        re.compile(r"(?<![A-Za-z0-9_])github_pat_(?P<value>[A-Za-z0-9_]{60,})"),
    ),
    (
        "a bearer credential",
        re.compile(r"\b(?i:bearer)\s+(?P<value>[A-Za-z0-9._~+/=-]{20,})"),
    ),
    (
        "a private key",
        re.compile(
            r"-----BEGIN (?:[A-Z0-9]+ )*PRIVATE KEY-----[ \t]*\r?\n"
            r"(?:[A-Za-z-]+:[^\n]*\n|[ \t]*\r?\n)*"
            r"[ \t]*(?P<value>[A-Za-z0-9+/=]{40,})"
        ),
    ),
)


def _is_placeholder(match: re.Match[str]) -> bool:
    """Say whether a match is a documented placeholder rather than a real credential."""
    if _PLACEHOLDER_WORD in match.group(0).upper():
        return True
    return len(set(match.group("value"))) < _MIN_DISTINCT_CHARS


def find_credential(text: str) -> tuple[str, int] | None:
    """Return (kind, 1-based line) of the first real credential in *text*, or None."""
    for kind, pattern in _SHAPES:
        for match in pattern.finditer(text):
            if not _is_placeholder(match):
                return kind, text.count("\n", 0, match.start()) + 1
    return None


def _reason(path: str, kind: str, line: int) -> str:
    """Build the block message. It never includes the matched value."""
    return (
        f"Blocked: the new content for {path} has {kind} on line {line} of the written "
        "text. Remove it, or reference it instead (an environment variable or a secrets "
        "manager), or use a documented placeholder such as an ...EXAMPLE value, then write "
        "again. The matched value is not shown."
    )


def _unadapted_bodies(payload: dict) -> list[tuple[str, str]]:
    """Return (path, text) pairs the shared adapter does not read.

    Claude Code `MultiEdit` sends `edits[].new_string`, and `NotebookEdit` sends
    `notebook_path` and `new_source`.
    """
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return []
    path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    path = path if isinstance(path, str) else ""
    bodies = []
    edits = tool_input.get("edits")
    if isinstance(edits, list):
        for edit in edits:
            if isinstance(edit, dict) and isinstance(edit.get("new_string"), str):
                bodies.append((path, edit["new_string"]))
    source = tool_input.get("new_source")
    if isinstance(source, str):
        bodies.append((path, source))
    return bodies


def _bodies(raw: str) -> list[tuple[str, str]]:
    """Return every (path, new text) pair the call would write. Unreadable input gives []."""
    payload = load_payload(raw)
    if payload is None:
        return []
    try:
        targets = read_targets(payload)
    except HookInputError:
        targets = []
    bodies = [(t.path, t.body) for t in targets if t.verb not in ("delete", "move_from")]
    return bodies + _unadapted_bodies(payload)


def main() -> None:
    """Read the PreToolUse payload from stdin and block a write holding a credential."""
    for path, body in _bodies(sys.stdin.read()):
        found = find_credential(body)
        if found is not None:
            kind, line = found
            print(_reason(path, kind, line), file=sys.stderr)
            sys.exit(2)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        # Fail open: a bug must skip the check, not lock every write.
        print(
            f"guard_secret_content: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
        sys.exit(0)
