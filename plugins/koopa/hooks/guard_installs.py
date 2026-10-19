#!/usr/bin/env python3
"""PreToolUse hook: ask the user before a command installs software.

Covers language package managers (`pip`, `npm`, `cargo`, ...), system package
managers (`brew`, `apt`, `dnf`, ...), `koopa install`, R package installs, and
network installers piped to a shell (`curl ... | sh`).

An install changes dependencies, so it needs explicit user approval: the hook answers
`permissionDecision: ask` and never approves on the user's behalf. Read-only probes
(`pip list`, `brew list`, `npm ls`, ...) are not installs and pass with no decision,
so the normal permission flow applies.

It asks about a command that RUNS an install, not text that mentions one. The
decision comes from `guard_installs_scan.py`, which reads the command the way a shell
does, including wrappers (`sudo`, `env`), `bash -c "..."`, `ssh host '...'`,
substitutions, heredocs fed to a shell, and every entry of a Copilot CLI
`toolCalls[]` batch. When that parser cannot decide, the text patterns below decide,
and a match asks.

Output shape follows the harness. Claude Code and Codex get the decision wrapped in
`hookSpecificOutput`. Copilot CLI gets a bare top-level `permissionDecision`; the
Copilot registration sets `AGENT_HOOK_HARNESS=copilot` in the command to select it.
The hook exits 0 in every case; empty or malformed stdin prints nothing.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import os
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
    "This command installs software, which changes dependencies, so the user must "
    "approve it. Read-only probes such as pip list or brew list need no approval."
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
    if installs("\n".join(read_commands(payload))):
        print(json.dumps(_ask_output()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
