#!/usr/bin/env python3
"""Decide whether a shell command line would install software.

Used by `guard_installs.py`. That guard used to match install phrases such as
`pip install` anywhere in the raw command text, so it also flagged a command
that only mentioned one: a commit message, a `grep` pattern, a heredoc body
holding documentation, or a comment. This scanner asks the question the guard
cares about: would an install command run?

Exit codes of `main` (a debugging aid; the guard imports the module):
    0   no install command found
    10  an install command was found
    3   the command could not be parsed with confidence
    any other code (a crash, a missing interpreter) also means "could not decide"

When the scanner cannot decide, the guard falls back to its text patterns, so a
scanner failure never lets an install through without an approval prompt and
never prompts for an ordinary command.

What counts as an install:
    * a package manager's install verb as the first non-flag argument:
      `pip install`, `npm i`, `brew install`, `apt-get install`, `cargo
      install`, `gem update`, `pipx upgrade`, `uv add`, `koopa install`, ...
    * `python -m pip install`, `pacman -S`, and any `cpan`/`cpanm` call
    * the same commands behind a wrapper (`sudo`, `env`, `nohup`, `xargs`) or
      inside `bash -c "..."`, `ssh host '...'` (quoted or not), `$(...)`, or a heredoc or pipe
      that reaches a shell
    * R package installs given to an interpreter (`Rscript -e
      'install.packages("x")'`)
    * a downloader piped into a shell (`curl ... | sh`) or run through
      `sh -c "$(curl ...)"`

What does not count: the same words inside quoted text given to a data command
(`echo`, `grep`, `git commit -m`), a comment, or a heredoc fed to a non-shell
command. `uninstall`, `reinstall`, and `pip list` are not installs.

`koopa` commands that change the system (`install`, `reinstall`, `sync`,
`uninstall`, `update`, `configure`, every `admin` subcommand, `system prune-apps` and
`system switch-to-develop`) get their own decision, `koopa_agent_decision`: the
`koopa` CLI refuses them under a coding agent, so the guard denies them unless the
same command line turns agent mode off, which asks instead.
"""

import re
import sys

from shell_command_scan import WRAPPERS, base, command_index, walk

EXIT_CLEAN = 0
EXIT_FOUND = 10
EXIT_UNSURE = 3

_PIP = re.compile(r"^pip[0-9.]*$")
_PYTHON = re.compile(r"^python[0-9.]*$")
_R_INSTALL = re.compile(r"install\.packages\(|(?:BiocManager|renv)::install\(")

INSTALL_VERBS = {
    "apt": {"install"},
    "apt-get": {"install"},
    "brew": {"install"},
    "cargo": {"install", "update"},
    "dnf": {"install"},
    "gem": {"install", "update"},
    "go": {"install"},
    "koopa": {"install"},
    "npm": {"install", "i", "update", "add"},
    "pipx": {"install", "upgrade"},
    "pnpm": {"install", "add", "update"},
    "poetry": {"add"},
    "port": {"install"},
    "yarn": {"install", "add", "update"},
    "yum": {"install"},
}
DOWNLOADERS = frozenset({"curl", "wget"})
SHELLS = frozenset({"bash", "sh", "zsh"})

# Mirrors `koopa.agent_mode`, which this hook cannot import: under a coding agent the
# `koopa` CLI refuses these commands, so the guard denies them up front instead of
# asking for an approval the CLI would then ignore. `test_agent_mode.py` keeps the
# copies in step.
KOOPA_AGENT_MARKERS = (
    "AI_AGENT",
    "PI_CODING_AGENT",
    "CLAUDE_CODE_CHILD_SESSION",
    "COPILOT_CLI",
    "GEMINI_CLI",
)
KOOPA_AGENT_OVERRIDE = "KOOPA_AGENT"
KOOPA_GATED_COMMANDS = frozenset(
    {"configure", "install", "reinstall", "sync", "uninstall", "update"}
)
KOOPA_GATED_SUBCOMMANDS = {
    "admin": None,
    "system": frozenset({"prune-apps", "switch-to-develop"}),
}
_KOOPA_AGENT_ENV = frozenset((*KOOPA_AGENT_MARKERS, KOOPA_AGENT_OVERRIDE))
_HELP_FLAGS = frozenset({"-h", "--help"})


def _first_arg(rest):
    """Return the first argument that is not a flag, or None."""
    for token in rest:
        if not token.startswith("-"):
            return token
    return None


def _is_install(argv):
    """True if *argv* (a command and its arguments) is an install command."""
    if not argv:
        return False
    name = base(argv[0])
    rest = argv[1:]
    if _PIP.match(name):
        return _first_arg(rest) == "install"
    if _PYTHON.match(name):
        if "-m" in rest:
            after = rest[rest.index("-m") + 1 :]
            return bool(after) and bool(_PIP.match(after[0])) and _first_arg(after[1:]) == "install"
        return False
    if name == "uv":
        first = _first_arg(rest)
        if first == "add":
            return True
        return first == "pip" and _first_arg(rest[rest.index("pip") + 1 :]) == "install"
    if name in ("cpan", "cpanm"):
        return bool(rest)
    if name == "pacman":
        return "-S" in rest
    verbs = INSTALL_VERBS.get(name)
    return bool(verbs) and _first_arg(rest) in verbs


def _candidates(argv):
    """The command itself, and after a wrapper or `ssh` every suffix that could
    be the real command (`sudo -u root pip install x` -> `pip install x`).
    """
    if not argv:
        return
    yield argv
    # `ssh host pip install x` runs its unquoted remote words as a command.
    if base(argv[0]) in WRAPPERS or base(argv[0]) == "ssh":
        for i in range(1, len(argv)):
            yield argv[i:]


def _runs_install(invocation):
    if any(_is_install(candidate) for candidate in _candidates(invocation.argv)):
        return True
    if invocation.pipeline & DOWNLOADERS and invocation.pipeline & SHELLS:
        return True  # curl ... | sh
    if invocation.argv and base(invocation.argv[0]) in SHELLS:
        if invocation.sub_names & DOWNLOADERS:
            return True  # sh -c "$(curl ...)"
    return any(_R_INSTALL.search(payload) for payload in invocation.payloads)


def runs_install(command):
    """True if *command* would run an install. Raises ParseError if unsure."""
    return any(_runs_install(invocation) for invocation in walk(command))


def _koopa_gated(argv):
    """True if *argv*, starting at its command word, is a `koopa` command that changes
    the system: one the CLI refuses under a coding agent.
    """
    if not argv or base(argv[0]) != "koopa" or _HELP_FLAGS & set(argv[1:]):
        return False
    words = [word for word in argv[1:] if not word.startswith("-")]
    if not words:
        return False
    if words[0] in KOOPA_GATED_COMMANDS:
        return True
    if words[0] not in KOOPA_GATED_SUBCOMMANDS or len(words) < 2:
        return False
    allowed = KOOPA_GATED_SUBCOMMANDS[words[0]]
    return allowed is None or words[1] in allowed


def _names_agent_env(word):
    """True if *word* names an agent marker or the override, alone or as `NAME=value`."""
    return word.split("=", 1)[0] in _KOOPA_AGENT_ENV


def _wrapper_overrides(prefix):
    """True if the wrapper words before a command change agent mode: `env NAME=...`,
    `env -u NAME`, or `env -i`.
    """
    for i, word in enumerate(prefix):
        if word in ("-i", "--ignore-environment"):
            return True
        if word in ("-u", "--unset") and i + 1 < len(prefix) and _names_agent_env(prefix[i + 1]):
            return True
        if word.startswith("--unset=") and _names_agent_env(word.split("=", 1)[1]):
            return True
        if "=" in word and not word.startswith("-") and _names_agent_env(word):
            return True
    return False


def koopa_agent_decision(command):
    """Decide on the `koopa` commands in *command* that change the system.

    Returns "deny" when one runs, since the CLI refuses it under an agent anyway;
    "ask" when the command line also turns agent mode off (`KOOPA_AGENT=0 koopa ...`,
    `env -u AI_AGENT koopa ...`, `unset COPILOT_CLI; koopa ...`), because then the
    install would really run and the user must approve it; and None otherwise.
    Raises ParseError if unsure.
    """
    gated = False
    override = False
    for invocation in walk(command):
        argv = invocation.argv
        if argv and base(argv[0]) in ("export", "unset"):
            override = override or any(_names_agent_env(word) for word in argv[1:])
        start = command_index(argv)
        if start is None or not _koopa_gated(argv[start:]):
            continue
        gated = True
        if any(name in _KOOPA_AGENT_ENV for name, _ in invocation.assignments):
            override = True
        if _wrapper_overrides(argv[:start]):
            override = True
    if not gated:
        return None
    return "ask" if override else "deny"


def main():
    text = sys.stdin.read()
    try:
        found = runs_install(text)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return EXIT_UNSURE
    return EXIT_FOUND if found else EXIT_CLEAN


if __name__ == "__main__":
    sys.exit(main())
