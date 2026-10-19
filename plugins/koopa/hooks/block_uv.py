#!/usr/bin/env python3
"""PreToolUse hook: ask the user before `uv` or `uvx` changes dependencies.

`uv` and `uvx` can mutate the local environment, install packages, rewrite the
lockfile, and launch tools they download first. Any such call (`uv sync`,
`uv add`, `uv pip install`, `uv run`, `uvx ...`) needs explicit user approval: the
hook answers `permissionDecision: ask` and never approves on the user's behalf.
Read-only probes (`uv --version`, `uv pip list`, `uv tree --frozen`, `uv lock
--check`, ...) pass with no decision, so the normal permission flow applies. The
probe allowlist lives in `uv_command_scan.py`; anything not on it asks.

Detection covers indirect calls: `bash -lc "uv pip install ..."`, `ssh host 'uvx
...'`, wrappers such as `sudo` and `env`, substitutions, heredocs fed to a shell,
and every entry of a Copilot CLI `toolCalls[]` batch. The scanner reads the command
the way a shell does: quoted text given to data commands (`echo`, `grep`, `git
commit -m`), comments, and heredoc bodies fed to non-shell commands pass. When the
parser cannot decide, the broad text pattern below decides, and a match asks.

Output shape follows the harness. Claude Code and Codex get the decision wrapped in
`hookSpecificOutput`. Copilot CLI gets a bare top-level `permissionDecision`; the
Copilot registration sets `AGENT_HOOK_HARNESS=copilot` in the command to select it.
The hook exits 0 in every case; empty or malformed stdin prints nothing.

The file keeps its historical name so existing registrations stay valid.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import os
import re
import sys

from hook_adapter import load_payload, read_commands
from uv_command_scan import CHANGE, uv_verdict

# The pattern this guard applies on its own when the scanner cannot decide.
_BROAD = re.compile(r"(^|[^A-Za-z0-9_-])(uvx?)(\s|$)", re.MULTILINE)

REASON = (
    "This command runs uv or uvx in a way that can change dependencies, the "
    "environment, or the lockfile, so the user must approve it. Read-only probes "
    "(uv --version, uv pip list, uv tree --frozen, uv lock --check) need no approval."
)


def needs_approval(command: str) -> bool:
    """True when *command* may change dependencies through uv or uvx.

    When the scanner cannot decide, the broad pattern decides, so any uv word asks.
    """
    try:
        return uv_verdict(command) == CHANGE
    except Exception:  # ParseError, RecursionError, anything unexpected
        return bool(_BROAD.search(command))


def _ask_output() -> dict:
    """The ask decision in the shape of the running harness."""
    if os.environ.get("AGENT_HOOK_HARNESS") == "copilot":
        return {"permissionDecision": "ask", "permissionDecisionReason": REASON}
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": REASON,
        }
    }


def main() -> int:
    """Read the hook payload from stdin, print an ask decision if needed, return 0."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    if needs_approval("\n".join(read_commands(payload))):
        print(json.dumps(_ask_output()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
