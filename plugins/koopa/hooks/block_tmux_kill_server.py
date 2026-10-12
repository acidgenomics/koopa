#!/usr/bin/env python3
"""PreToolUse hook: block `tmux ... kill-server` on any socket.

`kill-server` tears down every session on the target socket, not just the caller's
own job. Concurrent automated jobs share a named socket safely, and `kill-server`
defeats that: an unrelated session's job dies with no way to recover it. Teardown
must always be scoped to one session: `kill-session -t <name>`.

It blocks a command that RUNS tmux kill-server, not text that mentions it. The shell
parser in `shell_command_scan.py` reads the command the way a shell does and sees
through `ssh host '...'`, `bash -c "..."`, and `$(...)`. When the parser cannot
decide, the original text pattern decides instead.

Input is a Claude Code `tool_input.command` payload or a Copilot CLI `toolCalls[]`
batch. Empty or malformed stdin passes (exit 0). A block prints the reason to stderr
and exits 2.

Run as a script, Python puts this file's directory first on `sys.path`, so the two
sibling modules import without any path setup.
"""

import re
import sys

from hook_adapter import load_payload, read_commands
from shell_command_scan import base, command_index, walk

REASON = (
    "tmux kill-server tears down every session on the socket, including concurrent "
    "sessions' jobs you cannot see or recover. Use kill-session -t <job-name> to tear "
    "down only your own session."
)

_FALLBACK = re.compile(r"(^|[^A-Za-z0-9_-])tmux([\s]+[^\s]+)*[\s]+kill-server([^A-Za-z0-9_-]|$)")


def runs_tmux_kill_server(command: str) -> bool:
    """Say whether a shell command line would run `tmux ... kill-server`.

    Raises whatever the shell parser raises when it cannot parse with confidence.
    """
    for invocation in walk(command):
        start = command_index(invocation.argv)
        if start is None:
            continue
        argv = invocation.argv[start:]
        if base(argv[0]) == "tmux" and "kill-server" in argv[1:]:
            return True
    return False


def should_block(command: str) -> bool:
    """Decide with the parser, falling back to the text pattern when it cannot."""
    try:
        return runs_tmux_kill_server(command)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return _FALLBACK.search(command) is not None


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    command = "\n".join(read_commands(payload))
    if should_block(command):
        sys.stderr.write('{"decision":"block","reason":"' + REASON + '"}\n')
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
