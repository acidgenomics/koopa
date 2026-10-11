#!/usr/bin/env python3
"""PreToolUse hook: block software install commands.

Covers language package managers (`pip`, `npm`, `cargo`, ...), system package
managers (`brew`, `apt`, `dnf`, ...), `koopa install`, R package installs, and
network installers piped to a shell (`curl ... | sh`).

This is an opinionated default and a HARD block: there is no override. If you
really need the command, run it yourself in the terminal (in Claude Code, type `!`
before the command).

It blocks a command that RUNS an install, not text that mentions one. The decision
comes from `guard_installs_scan.py`, which reads the command the way a shell does.
When that parser cannot decide, the text patterns below decide instead.

Input is a Claude Code `tool_input.command` payload or a Copilot CLI `toolCalls[]`
batch. Empty or malformed stdin passes (exit 0). A block prints the reason to stderr
and exits 2.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import re
import sys

from guard_installs_scan import runs_install
from hook_adapter import load_payload, read_commands

# Each pattern is anchored to avoid partial hits (for example "reinstall" or
# "uninstall"): preceded by the start of the string, whitespace, or one of `;|&`.
_B = r"(?:^|[\s;|&])"
_END = r"(?:\s|$)"

_INSTALL_PATTERNS = tuple(
    re.compile(pattern)
    for pattern in (
        # Language package managers
        _B + r"(?:pip|pip3)\s+install" + _END,
        _B + r"python\s+-m\s+pip\s+install" + _END,
        _B + r"uv\s+(?:add|pip\s+install)" + _END,
        _B + r"pipx\s+(?:install|upgrade)" + _END,
        _B + r"npm\s+(?:install|i|update|add)" + _END,
        _B + r"(?:pnpm|yarn)\s+(?:install|add|update)" + _END,
        _B + r"poetry\s+add" + _END,
        _B + r"gem\s+(?:install|update)" + _END,
        _B + r"cargo\s+(?:install|update)" + _END,
        _B + r"go\s+install" + _END,
        _B + r"(?:cpan|cpanm)\s",
        # R package managers
        r"install\.packages\(",
        r"(?:BiocManager|renv)::install\(",
        # System package managers
        _B + r"brew\s+install" + _END,
        _B + r"(?:apt|apt-get)\s+install" + _END,
        _B + r"(?:dnf|yum)\s+install" + _END,
        _B + r"pacman\s+-S" + _END,
        _B + r"port\s+install" + _END,
        # koopa installer
        _B + r"koopa\s+install" + _END,
    )
)
_PIPE_TO_SHELL = re.compile(r"\|\s*(?:bash|sh|zsh)(?:\s|$)")
_DOWNLOADER = re.compile(r"(?:curl|wget)\s")

REASON = (
    "Software installs are not allowed. Surface the command or koopa app name and let "
    "the user install it."
)


def matches_install_text(command: str) -> bool:
    """True when a text pattern says *command* installs software (the parser fallback)."""
    if any(pattern.search(command) for pattern in _INSTALL_PATTERNS):
        return True
    return bool(_PIPE_TO_SHELL.search(command) and _DOWNLOADER.search(command))


def installs(command: str) -> bool:
    """True when *command* installs software, using the text patterns if the parser fails."""
    try:
        return runs_install(command)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return matches_install_text(command)


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    if not installs("\n".join(read_commands(payload))):
        return 0
    sys.stderr.write(json.dumps({"decision": "block", "reason": REASON}) + "\n")
    return 2


if __name__ == "__main__":
    sys.exit(main())
