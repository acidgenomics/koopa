#!/usr/bin/env python3
"""PreToolUse hook: block broad filesystem scans rooted at home or the system root.

A scan is "broad" when its root is `~`, `$HOME`, `/`, `/Users`, `/home`, or a bare
home directory (`/Users/<name>` or `/home/<name>` with no further subpath). Scans
rooted in deeper project subdirectories are allowed. Covers `find`, `grep -r`/`-R`,
`rg`, and `fd`/`fdfind`.

This is an opinionated default and a HARD block: there is no override. If you
really need the scan, run it yourself in the terminal (in Claude Code, type `!`
before the command).

The check is text based, one line at a time (the words are split on whitespace and
quotes are not interpreted). Input is a Claude Code `tool_input.command` payload or
a Copilot CLI `toolCalls[]` batch. Empty or malformed stdin passes (exit 0), and so
does any unexpected error. A block prints the reason to stderr and exits 2.

Run as a script, Python puts this file's directory first on `sys.path`, so the
sibling modules import without any path setup.
"""

import json
import re
import sys

from hook_adapter import load_payload, read_commands

_FIND = re.compile(r"(^|\s)find\s")
_GREP_RECURSIVE = re.compile(r"(^|\s)grep\s+-[a-zA-Z]*[rR]")
_RG = re.compile(r"(^|\s)rg\s")
_FD = re.compile(r"(^|\s)(fd|fdfind)\s")
_BROAD_WORDS = frozenset({"~", "~/", "$HOME", "${HOME}", "/", "/Users", "/home"})

REASON = (
    "Broad filesystem scan blocked. Scope the search to the project directory or a "
    "known subpath, not the home directory or system root. Ask the user if a wider "
    "scan is genuinely needed."
)


def is_broad_root(raw: str) -> bool:
    """True when *raw* is a home alias, a system-level root, or a bare home directory."""
    path = raw if raw in ("/", "~/") else raw.removesuffix("/")
    if path in _BROAD_WORDS:
        return True
    for prefix in ("/Users/", "/home/"):
        if path.startswith(prefix):
            return "/" not in path[len(prefix) :]
    return False


def _has_broad_path_token(words: list[str]) -> bool:
    """True when any non-flag word is a broad root (grep, rg, and fd take positional paths)."""
    return any(is_broad_root(word) for word in words if word and not word.startswith("-"))


def _find_root(words: list[str]) -> str:
    """The search root of a `find` call: the first non-flag word, skipping -H, -L, -P."""
    for word in words:
        if word in ("-H", "-L", "-P"):
            continue
        if word.startswith("-"):
            return ""
        return word
    return ""


def _line_is_broad_scan(line: str) -> bool:
    """True when one command line is a broad `find`, `grep -r`, `rg`, or `fd` scan."""
    words = line.split()
    if _FIND.search(line):
        root = _find_root(line.partition("find ")[2].split() if "find " in line else words)
        if root and is_broad_root(root):
            return True
    if _GREP_RECURSIVE.search(line) and _has_broad_path_token(words):
        return True
    if _RG.search(line) and _has_broad_path_token(words):
        return True
    return bool(_FD.search(line) and _has_broad_path_token(words))


def is_broad_scan(command: str) -> bool:
    """True when any line of *command* is a broad filesystem scan."""
    return any(_line_is_broad_scan(line) for line in command.splitlines())


def main() -> int:
    """Read the hook payload from stdin and return the process exit code."""
    try:
        payload = load_payload(sys.stdin.read())
        if payload is None:
            return 0
        broad = any(is_broad_scan(command) for command in read_commands(payload))
    except Exception:
        return 0
    if not broad:
        return 0
    sys.stderr.write(json.dumps({"decision": "block", "reason": REASON}) + "\n")
    return 2


if __name__ == "__main__":
    sys.exit(main())
