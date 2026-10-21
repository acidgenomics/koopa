"""Agent mode: koopa will not change the system when a coding agent runs it.

Agent harnesses differ in which guard hooks they run: some run the koopa plugin's
hooks, others run none. So the rule that an agent never installs, removes, or
reconfigures software lives in the ``koopa`` CLI itself, which every harness calls.
When a process marker shows a coding agent launched the command, ``koopa`` refuses
every command that changes the system and prints the exact command for the user to
run in their own terminal.

The plugin hook ``guard_installs_scan.py`` keeps its own copy of the gated command
lists, because it cannot import this package; ``test_agent_mode.py`` keeps the two
in step.
"""

import shlex
from collections.abc import Mapping, Sequence

#: Process markers coding agents set for the commands they run: ``AI_AGENT`` (Pi, and
#: VS Code Copilot agent terminals; a plain VS Code integrated terminal sets none),
#: ``PI_CODING_AGENT`` (Pi), ``CLAUDE_CODE_CHILD_SESSION`` (every shell Claude Code
#: spawns, ``!`` commands included; the broader ``CLAUDECODE`` is also set in IDE
#: terminals a person types into, so it is not used), ``COPILOT_CLI`` (Copilot CLI), and
#: ``GEMINI_CLI`` (Gemini CLI shell tool).
AGENT_MARKERS: tuple[str, ...] = (
    "AI_AGENT",
    "PI_CODING_AGENT",
    "CLAUDE_CODE_CHILD_SESSION",
    "COPILOT_CLI",
    "GEMINI_CLI",
)

#: Explicit override: ``1`` forces agent mode on, ``0`` turns it off.
AGENT_OVERRIDE = "KOOPA_AGENT"

#: Top-level commands that change the system.
GATED_COMMANDS = frozenset({"configure", "install", "reinstall", "uninstall", "update"})

#: Command groups with subcommands that change the system. ``None`` gates every
#: subcommand of the group.
GATED_SUBCOMMANDS: Mapping[str, frozenset[str] | None] = {
    "admin": None,
    "system": frozenset({"prune-apps", "switch-to-develop"}),
}

_HELP_FLAGS = frozenset({"-h", "--help"})


def is_agent_session(env: Mapping[str, str]) -> bool:
    """Return whether a coding agent launched this process.

    Parameters
    ----------
    env : Mapping[str, str]
        The process environment, normally ``os.environ``.

    Returns
    -------
    bool
        True when ``KOOPA_AGENT`` is set to anything but ``0``, or when it is unset or
        empty and any of :data:`AGENT_MARKERS` holds a non-empty value.
    """
    override = env.get(AGENT_OVERRIDE, "").strip()
    if override:
        return override != "0"
    return any(env.get(marker, "").strip() for marker in AGENT_MARKERS)


def is_gated(command: str, remainder: Sequence[str]) -> bool:
    """Return whether a parsed ``koopa`` command changes the system.

    Parameters
    ----------
    command : str
        The top-level command, such as ``install`` or ``system``.
    remainder : Sequence[str]
        The words after a group command (``system``, ``admin``); empty otherwise.

    Returns
    -------
    bool
        True for a gated top-level command, or for a gated subcommand of a group. A
        group call that asks only for help is not gated.
    """
    if command in GATED_COMMANDS:
        return True
    if command not in GATED_SUBCOMMANDS or not remainder:
        return False
    if _HELP_FLAGS & set(remainder):
        return False
    allowed = GATED_SUBCOMMANDS[command]
    return allowed is None or remainder[0] in allowed


def refusal_message(argv: Sequence[str]) -> str:
    """Return the message printed when agent mode refuses a command.

    Parameters
    ----------
    argv : Sequence[str]
        The arguments after ``koopa``.

    Returns
    -------
    str
        A message that names the exact command for the user to run.
    """
    return (
        "koopa: a coding agent is running this command, and it changes the system, so "
        "koopa will not run it.\n"
        "Ask the user to run it in their own terminal:\n\n"
        f"    {shlex.join(['koopa', *argv])}\n"
    )
