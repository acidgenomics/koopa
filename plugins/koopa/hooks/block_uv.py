#!/usr/bin/env python3
"""PreToolUse hook: block the `uv` / `uvx` toolchain.

Agents must not run `uv` or `uvx`: they can mutate the local environment, install
packages, and silently change dependency state in ways that bypass a project's
intended workflow. The block covers `uv`, `uvx`, and their wrappers (`uv sync`,
`uv pip install`, `uv run`, `uvx ...`), including indirect calls such as
`bash -lc "uv pip install ..."` and `ssh host 'uvx ...'`.

This is an opinionated default and a HARD block: there is no override. If you
really need the command, run it yourself in the terminal (in Claude Code, type `!`
before the command).

It blocks a command that RUNS uv, not text that mentions it. The decision comes from
`uv_command_scan.py`, which reads the command the way a shell does: quoted text given
to data commands (`echo`, `grep`, `git commit -m`), comments, and heredoc bodies fed
to non-shell commands pass; unquoted uv, substitutions, and text handed to a shell
(`bash -c`, `ssh`, `| sh`) block. Fail closed: when the parser cannot decide, the
broad text pattern below decides instead.

Input is a Claude Code `tool_input.command` payload or a Copilot CLI `toolCalls[]`
batch. Empty or malformed stdin passes (exit 0). A block prints the reason to stderr
and exits 2.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import re
import sys

from hook_adapter import load_payload, read_commands
from uv_command_scan import runs_uv

# The pattern this guard applies on its own when the scanner cannot decide.
_BROAD = re.compile(r"(^|[^A-Za-z0-9_-])(uvx?)(\s|$)", re.MULTILINE)

REASON = (
    "Agentic use of uv and uvx is forbidden. No uv/uvx commands, installs, or tool "
    "launches are allowed. Use the project environment and scripts instead."
)


def uses_uv(command: str) -> bool:
    """True when *command* runs uv or uvx, using the broad pattern if the parser fails."""
    try:
        return runs_uv(command)
    except Exception:  # ParseError, RecursionError, anything unexpected: fail closed
        return bool(_BROAD.search(command))


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    if not uses_uv("\n".join(read_commands(payload))):
        return 0
    sys.stderr.write(json.dumps({"decision": "block", "reason": REASON}) + "\n")
    return 2


if __name__ == "__main__":
    sys.exit(main())
