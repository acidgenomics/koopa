#!/usr/bin/env python3
"""PreToolUse hook: ask before a Bash command touches ~/Documents or ~/Downloads.

Never denies. It forces an approval prompt (`permissionDecision: ask`) when a shell command
names a personal folder that usually holds files the agent has no reason to read.

A reference is `Documents` or `Downloads` directly under the home directory, spelled `~`,
`$HOME`, `${HOME}` or `/Users/<name>`. The match needs a boundary on both sides: the text
before it must not be a letter, digit, `_`, `.` or `/` (so `./MyDocuments` and
`/opt/Users/x/Documents` pass), and the text after it must be `/`, whitespace, a quote, `;`,
`&`, `|` or the end of the command (so `~/Documents-old` passes).

Exemptions come from the git config key `koopa.allowedPaths`. It is multi-valued; each value
is a path relative to the home directory that starts with `Documents` or `Downloads`, for
example `Documents/notes`. A reference is exempt when it sits at or under an allowed path,
matched at a path-segment boundary: `Documents/notes` exempts `~/Documents/notes` and
`~/Documents/notes/a.md` but not `~/Documents/notes-old`. A path that climbs out with `..`
after the allowed prefix is not exempt. With no value configured nothing is exempt. Every
reference in the command must be exempt for the command to pass without a prompt.

```sh
git config --global --add koopa.allowedPaths Documents/notes
```

Output shape follows the harness. Claude Code and Codex get the decision wrapped in
`hookSpecificOutput`. Copilot CLI gets a bare top-level `permissionDecision`; the Copilot
registration sets `AGENT_HOOK_HARNESS=copilot` in the command to select it.

Fails open: any error, or no readable command, exits 0 with no output.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` and `guard_keywords.py`
beside it, and Python 3.10 or newer.
"""

import json
import os
import re
import sys

from guard_keywords import _config_values
from hook_adapter import load_payload, read_commands

_ALLOWED_PATHS_KEY = "koopa.allowedPaths"
_REASON = (
    "Command references a protected path (~/Documents or ~/Downloads): confirm before proceeding."
)

# Boundaries are lookarounds so that a match consumes nothing but the path itself.
_LEAD = r"(?<![A-Za-z0-9_./])"
_HOME = r"(?:~|\$HOME|\$\{HOME\}|/Users/[^/\s]+)"
_TRAIL = r"(?=[/\s\"';&|]|$)"
_REFERENCE = re.compile(f"{_LEAD}{_HOME}/(?:Documents|Downloads){_TRAIL}", re.MULTILINE)
_TOKEN_END = re.compile(r"[\s\"';&|]")
_CLIMBS = re.compile(r"(?:^|/)\.\.(?:/|$)")


def _allowed_patterns() -> re.Pattern[str] | None:
    """Compile `koopa.allowedPaths` into a matcher for the part after the home directory."""
    alternatives: list[str] = []
    for value in _config_values(_ALLOWED_PATHS_KEY):
        parts = [part for part in value.strip().strip("/").split("/") if part]
        if not parts or parts[0] not in ("Documents", "Downloads") or ".." in parts:
            continue
        alternatives.append("/".join(re.escape(part) for part in parts))
    if not alternatives:
        return None
    return re.compile(f"{_HOME}/(?:{'|'.join(alternatives)}){_TRAIL}")


def _exempt(command: str, start: int, allowed: re.Pattern[str] | None) -> bool:
    """True when the reference starting at `start` sits under an allowed path."""
    if allowed is None:
        return False
    hit = allowed.match(command, start)
    if hit is None:
        return False
    rest = command[hit.end() :]
    end = _TOKEN_END.search(rest)
    token = rest[: end.start()] if end else rest
    return _CLIMBS.search(token) is None


def should_ask(command: str) -> bool:
    """True when the command references a protected folder that is not exempt."""
    hits = list(_REFERENCE.finditer(command))
    if not hits:
        return False
    allowed = _allowed_patterns()
    return any(not _exempt(command, hit.start(), allowed) for hit in hits)


def _ask_output() -> dict:
    """The ask decision in the shape of the running harness."""
    if os.environ.get("AGENT_HOOK_HARNESS") == "copilot":
        return {"permissionDecision": "ask", "permissionDecisionReason": _REASON}
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": _REASON,
        }
    }


def main() -> int:
    """Read the PreToolUse payload from stdin and print an ask decision if needed."""
    try:
        payload = load_payload(sys.stdin.read())
        if payload is None:
            return 0
        if any(should_ask(command) for command in read_commands(payload)):
            print(json.dumps(_ask_output()))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
