#!/usr/bin/env python3
"""PreToolUse hook: ask the user before a command installs software.

Covers language package managers (`pip`, `npm`, `cargo`, ...), system package
managers (`brew`, `apt`, `dnf`, ...), `koopa install`, R package installs, and
network installers piped to a shell (`curl ... | sh`).

An install changes dependencies, so it needs explicit user approval: the hook answers
`permissionDecision: ask` and never approves on the user's behalf. Read-only probes
(`pip list`, `brew list`, `npm ls`, ...) are not installs and pass with no decision,
so the normal permission flow applies.

A `koopa` command that changes the system (`install`, `reinstall`, `uninstall`,
`update`, `configure`, `admin ...`, `system prune-apps`, `system switch-to-develop`)
is denied instead: the `koopa` CLI refuses it under a coding agent in every harness
(`koopa.agent_mode`), so asking would only collect an approval the CLI then ignores.
The deny reason tells the agent to show the user the command to run themselves. When
the same command line turns agent mode off (`KOOPA_AGENT=0 koopa ...`,
`env -u AI_AGENT koopa ...`), the command would really run, so the hook asks.

It asks about a command that RUNS an install, not text that mentions one. The
decision comes from `guard_installs_scan.py`, which reads the command the way a shell
does, including wrappers (`sudo`, `env`), `bash -c "..."`, `ssh host '...'`,
substitutions, heredocs fed to a shell, and every entry of a Copilot CLI
`toolCalls[]` batch. When that parser cannot decide, the text patterns below decide,
and a match asks.

Output shape follows the harness. Claude Code and Codex get the decision wrapped in
`hookSpecificOutput`. Copilot CLI gets a bare top-level `permissionDecision`; the
Copilot registration sets `AGENT_HOOK_HARNESS=copilot` in the command to select it.
A koopa deny writes `{"decision": "block", ...}` to stderr and exits 2, the shape the
other blocking hooks use; every other case exits 0, and empty or malformed stdin
prints nothing.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import os
import re
import sys

from guard_installs_scan import koopa_agent_decision, runs_install
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
        # koopa commands that change the system
        _B
        + r"koopa\s+(?:install|reinstall|uninstall|update|configure|admin\s+\S+"
        + r"|system\s+(?:prune-apps|switch-to-develop))"
        + _END,
    )
)
_PIPE_TO_SHELL = re.compile(r"\|\s*(?:bash|sh|zsh)(?:\s|$)")
_DOWNLOADER = re.compile(r"(?:curl|wget)\s")

REASON = (
    "This command installs software, which changes dependencies, so the user must "
    "approve it. Read-only probes such as pip list or brew list need no approval."
)
KOOPA_DENY_REASON = (
    "koopa will not change the system when a coding agent runs it, so this command "
    "would be refused. Ask the user to run it in their own terminal, and show them the "
    "exact command."
)
KOOPA_ASK_REASON = (
    "This command turns off koopa's agent mode so that a koopa command which changes "
    "the system really runs. The user must approve it."
)


def koopa_decision(command: str) -> str | None:
    """The agent-mode decision for koopa commands in *command*, or None.

    A command line the parser cannot read gets None here; the text patterns in
    `installs` then ask about it.
    """
    try:
        return koopa_agent_decision(command)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return None


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


def _ask_output(reason: str = REASON) -> dict:
    """The ask decision in the shape of the running harness."""
    if os.environ.get("AGENT_HOOK_HARNESS") == "copilot":
        return {"permissionDecision": "ask", "permissionDecisionReason": reason}
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": reason,
        }
    }


def main() -> int:
    """Read the hook payload from stdin; deny, ask, or stay silent; return the exit code."""
    payload = load_payload(sys.stdin.read())
    if payload is None:
        return 0
    command = "\n".join(read_commands(payload))
    decision = koopa_decision(command)
    if decision == "deny":
        sys.stderr.write(json.dumps({"decision": "block", "reason": KOOPA_DENY_REASON}) + "\n")
        return 2
    if decision == "ask":
        print(json.dumps(_ask_output(KOOPA_ASK_REASON)))
    elif installs(command):
        print(json.dumps(_ask_output()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
