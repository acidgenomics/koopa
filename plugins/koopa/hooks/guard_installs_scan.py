#!/usr/bin/env python3
"""Decide whether a shell command line would install software.

Used by `guard-installs.sh`. That guard used to match install phrases such as
`pip install` anywhere in the raw command text, so it also blocked a command
that only mentioned one: a commit message, a `grep` pattern, a heredoc body
holding documentation, or a comment. This scanner asks the question the guard
cares about: would an install command run?

Exit codes (read by guard-installs.sh):
    0   no install command found
    10  an install command was found
    3   the command could not be parsed with confidence
    any other code (a crash, a missing interpreter) also means "could not decide"

On anything other than 0 or 10 the caller falls back to its original text
patterns, so a scanner failure never lets an install through and never blocks
an ordinary command.

What counts as an install:
    * a package manager's install verb as the first non-flag argument:
      `pip install`, `npm i`, `brew install`, `apt-get install`, `cargo
      install`, `gem update`, `pipx upgrade`, `uv add`, `koopa install`, ...
    * `python -m pip install`, `pacman -S`, and any `cpan`/`cpanm` call
    * the same commands behind a wrapper (`sudo`, `env`, `nohup`, `xargs`) or
      inside `bash -c "..."`, `ssh host '...'`, `$(...)`, or a heredoc or pipe
      that reaches a shell
    * R package installs given to an interpreter (`Rscript -e
      'install.packages("x")'`)
    * a downloader piped into a shell (`curl ... | sh`) or run through
      `sh -c "$(curl ...)"`

What does not count: the same words inside quoted text given to a data command
(`echo`, `grep`, `git commit -m`), a comment, or a heredoc fed to a non-shell
command. `uninstall`, `reinstall`, and `pip list` are not installs.
"""

import re
import sys

from shell_command_scan import WRAPPERS, base, walk

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
    """The command itself, and after a wrapper every suffix that could be the
    real command (`sudo -u root pip install x` -> `pip install x`).
    """
    if not argv:
        return
    yield argv
    if base(argv[0]) in WRAPPERS:
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


def main():
    text = sys.stdin.read()
    try:
        found = runs_install(text)
    except Exception:  # ParseError, RecursionError, anything unexpected
        return EXIT_UNSURE
    return EXIT_FOUND if found else EXIT_CLEAN


if __name__ == "__main__":
    sys.exit(main())
