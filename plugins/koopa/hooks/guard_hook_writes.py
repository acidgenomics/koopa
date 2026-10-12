#!/usr/bin/env python3
"""PreToolUse hook: ask before a Bash command changes a guard hook or settings file.

The guard hooks under `~/.agents/hooks` (and the `~/.claude/hooks` symlink) and the
`settings.json` files are the safety layer. A broad allow rule such as `Bash(sed:*)`
or `Bash(python3:*)` lets a command rewrite them with no prompt. This hook forces a
prompt for that case. The fix it points to is to edit the chezmoi source and apply it.

Asks when one command both names a protected path and writes:

* Protected paths: `.agents/hooks`, `.claude/hooks`, and `.claude/settings*.json`,
  spelled with `~`, `$HOME`, `/Users/<name>`, or relative. The chezmoi source
  directory `dot_agents/hooks` does not match, so editing the source stays quiet.
* Writes: `sed -i`, `perl -i`, a redirect (`>`, `>>`, `>|`), `tee`, `mv`, `rm`,
  `rmdir`, `chmod`, `chown`, `truncate`, `touch`, `patch`; `cp`, `rsync`, `install`,
  and `ln` when the protected path is the destination; and interpreter code
  (`python3 -c`, a heredoc) that names a protected path next to a write call.
* A `cd` or `pushd` into a protected directory makes later writes in the same
  command count, because the file names are then relative.

Does not ask for reads and runs: `cat`, `ls`, `grep`, `cmp`, `diff`,
`python3 ~/.agents/hooks/guard_rm.py`, `pytest`, and `chezmoi apply`.

The file tools (`Write`, `Edit`) are not covered here: they already prompt for these
directories. This is a speed bump, not a security boundary: a script that writes
the file on its own is not seen.

Fails open: any error exits 0 with no output, so the normal permission flow runs.

Ships in the koopa plugin under `hooks/`. Needs `hook_adapter.py` and
`shell_command_scan.py` beside it, and Python 3.10 or newer.
"""

import json
import os
import re
import sys

from hook_adapter import load_payload, read_commands
from shell_command_scan import ParseError, command_index, walk

_PROTECTED = re.compile(r"\.(?:agents|claude)/hooks(?:/|$)|\.claude/settings[\w.-]*\.json")
_ANY_ARG = frozenset(
    {"mv", "rm", "rmdir", "chmod", "chown", "truncate", "touch", "patch", "tee", "unlink"}
)
_DEST_LAST = frozenset({"cp", "rsync", "install", "ln"})
_SED = frozenset({"sed", "gsed", "perl", "ruby"})
_NAV = frozenset({"cd", "pushd"})
_REDIRECT_BARE = re.compile(r"^(?:\d*|&)(?:>>?|>\|)$")
_REDIRECT_ATTACHED = re.compile(r"^(?:\d*|&)(?:>>?|>\|)(?P<target>[^&].*)$")
# `>| file`: the scanner reads the `|` as a pipe, so find this form in the raw text.
_CLOBBER = re.compile(r">\|\s*([\"']?)([^\s\"';&|)]+)\1")
_IN_PLACE = re.compile(r"^(?:--in-place\b|-[A-Za-z]*i)")
_WRITE_HINT = re.compile(
    r"open\(\s*[^,()]+,\s*[\"'][rwabxt+]*[wax+][rwabxt+]*[\"']"
    r"|write|unlink|remove|rename|replace|chmod|shutil|copy|move|symlink|rmtree|truncate|touch"
)

REASON = (
    "This command changes a guard hook or a settings file. Edit the chezmoi source instead, "
    "then apply it with `chezmoi apply <target>`."
)


def _protected(word: str) -> bool:
    """True when *word* names a protected hook or settings path."""
    return bool(_PROTECTED.search(word))


def _redirect_targets(argv: list[str]) -> tuple[list[str], list[str]]:
    """Return (words without redirects, redirect targets)."""
    words: list[str] = []
    targets: list[str] = []
    expect_target = False
    for word in argv:
        if expect_target:
            targets.append(word)
            expect_target = False
        elif _REDIRECT_BARE.match(word):
            expect_target = True
        elif match := _REDIRECT_ATTACHED.match(word):
            targets.append(match.group("target"))
        else:
            words.append(word)
    return words, targets


def _writes_protected(argv: list[str], payloads: list[str], in_protected_dir: bool) -> bool:
    """True when one simple command writes a protected path."""
    words, targets = _redirect_targets(argv)
    if targets and (in_protected_dir or any(_protected(t) for t in targets)):
        return True
    if any(_protected(p) and _WRITE_HINT.search(p) for p in payloads):
        return True
    start = command_index(words)
    if start is None:
        return False
    name = os.path.basename(words[start])
    args = words[start + 1 :]
    if name in _SED:
        in_place = any(_IN_PLACE.match(a) for a in args if a.startswith("-"))
        return in_place and (in_protected_dir or any(_protected(a) for a in args))
    if name in _ANY_ARG:
        return in_protected_dir or any(_protected(a) for a in args)
    if name in _DEST_LAST:
        plain = [a for a in args if not a.startswith("-")]
        return in_protected_dir or any(_protected(a) for a in plain[-1:])
    return False


def should_ask(command: str) -> bool:
    """True when the command writes a guard hook or settings file."""
    if any(_protected(m.group(2)) for m in _CLOBBER.finditer(command)):
        return True
    try:
        invocations = walk(command)
    except ParseError:
        return False
    in_protected_dir = False
    for inv in invocations:
        start = command_index(inv.argv)
        if start is not None and os.path.basename(inv.argv[start]) in _NAV:
            if any(_protected(a) for a in inv.argv[start + 1 :]):
                in_protected_dir = True
            continue
        if _writes_protected(inv.argv, inv.payloads, in_protected_dir):
            return True
    return False


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
    """Read the PreToolUse payload from stdin and print an ask decision if needed."""
    try:
        payload = load_payload(sys.stdin.read())
        if payload is None:
            return 0
        if any(should_ask(command) for command in read_commands(payload)):
            print(json.dumps(_ask_output()))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
