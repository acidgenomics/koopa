#!/usr/bin/env python3
"""PreToolUse hook: let `rm` clean up under $TMPDIR, block recursive-force `rm` elsewhere.

A settings.json deny rule such as `Bash(rm -rf *)` matches one spelling of the
flags (`rm -fr`, `rm -r -f`, and `rm --recursive --force` slip past it) and cannot
make an exception for scratch space. This hook reads the command the way a shell
does (see shell_command_scan.py) and decides on the real `rm` calls instead.

Decisions:

* allow: every command in the call is `rm` or `rmdir`, run directly, with only
  harmless flags, no redirect, no command substitution, and every path resolves
  (symlinks followed) to a place strictly inside $TMPDIR. $TMPDIR itself never
  qualifies. A path may start with `$TMPDIR` or `${TMPDIR}`; any other variable,
  a glob, a `~`, or a `..` makes the hook decline.
* deny: a recursive and forced `rm` whose targets are not all inside $TMPDIR. The
  `rm` may sit behind any wrapper (`sudo -u root`, `nice -n 5`, `xargs -n 1`,
  `timeout 5`), or behind `find -exec`, `-execdir`, `-ok`, or `-okdir`. `find ...
  -delete` is denied the same way unless every search root is inside $TMPDIR. A
  glob or a variable in a target counts as outside, because the hook cannot
  resolve it. A `cd` or a `TMPDIR=` assignment earlier in the command also puts
  the targets outside, since the hook cannot follow either. This keeps what the
  old deny rule did and closes its flag-order gap. The `rm` is found after a leading
  `NAME=value` (quoted or not) and after `do`, `then`, `else`, `{`, `!`, and the like.
* no decision, instead of deny: a recursive force `rm` of a bare `$NAME` or `${NAME}`
  that the same command text set from `NAME=$(mktemp -d ...)`. The directory is one
  the command just made, so removing it is not the hazard this hook exists for, and
  the same holds inside `ssh host '...'` or `bash -c '...'`, where $TMPDIR is not
  this machine's. The variable must be set once, in the same piece of text, before the
  `rm`, by a command that is only that assignment, and nothing else in that text may
  change it (`read`, `export`, `for NAME in`, `printf -v`, `unset`, `eval`, `source`). A
  suffix (`$NAME/x`, `$NAME/*`) does not qualify, since a failed `mktemp` leaves NAME
  empty and the target would be `/x`. This is a decision to stop denying, never to
  allow: the normal permission flow still runs.
* no decision (exit 0, no output): everything else, so the normal permission
  flow runs. The hook never decides when it cannot parse or inspect the call,
  except that unparsable text which clearly looks like `rm -rf` is still denied.

Which temp files are fair game is a behavior rule, not something a hook can
know: delete only what you created in this session.

Deployed from the public dotfiles tree to `~/.agents/hooks/guard_rm.py`.
Needs `hook_adapter.py` and `shell_command_scan.py` beside it, and Python 3.10
or newer.
"""

import json
import os
import re
import sys
from collections.abc import Callable

from hook_adapter import load_payload, read_commands
from shell_command_scan import Invocation, ParseError, command_index, walk

_RM_NAMES = frozenset({"rm", "rmdir"})
_NAV = frozenset({"cd", "pushd", "popd"})
_EXEC_FLAGS = frozenset({"-exec", "-execdir", "-ok", "-okdir"})
_FIND_EXPR_START = re.compile(r"^(?:-|!$|\()")
_FLAG_LETTERS = frozenset("rRfivdxPI")
_LONG_FLAGS = frozenset(
    {"--recursive", "--force", "--verbose", "--dir", "--one-file-system", "--interactive"}
)
_REDIRECT_OP = re.compile(r"^(?:\d*|&)(?:>>?|<)$")  # bare operator; the next word is its target
_REDIRECT_ATTACHED = re.compile(r"^(?:\d*|&)(?:>>?|<)")  # `>file`, `2>&1`
_UNSAFE_CHARS = re.compile(r"[$`*?\[\]{}!\n]")
_FRESH_VAR = re.compile(r"^\$(?:(\w+)|\{(\w+)\})$")
# Commands that can set a shell variable other than by `NAME=value`. Each one that names a
# variable counts as a second write to it. `eval` and `source` can set anything, so they
# rule out every variable in their scope.
_SETS_VARS = frozenset(
    {
        "declare",
        "export",
        "for",
        "getopts",
        "let",
        "local",
        "mapfile",
        "read",
        "readarray",
        "readonly",
        "select",
        "typeset",
        "unset",
    }
)
_OPAQUE = frozenset({"eval", "source", "."})

_DENY_REASON = (
    "Recursive force rm is blocked outside $TMPDIR. Name the exact files, ask the user, "
    "or clean up inside $TMPDIR."
)
_ALLOW_REASON = "rm targets resolve inside $TMPDIR."


def _exec_commands(argv):
    """Return the command words that `find` runs through -exec, -execdir, -ok, or -okdir."""
    found = []
    i = 0
    while i < len(argv):
        if argv[i] in _EXEC_FLAGS:
            end = i + 1
            while end < len(argv) and argv[end] not in (";", "+"):
                end += 1
            found.append(argv[i + 1 : end])
            i = end
        i += 1
    return found


def _find_roots(args):
    """Return the search roots of a `find` call (the words before its expression)."""
    roots = []
    for word in args:
        if _FIND_EXPR_START.match(word):
            break
        roots.append(word)
    return roots or ["."]


def _strip_redirects(args):
    """Drop redirect words and their targets. Return (remaining words, saw a redirect)."""
    clean = []
    saw = False
    skip_next = False
    for word in args:
        if skip_next:
            skip_next = False
            continue
        if _REDIRECT_OP.match(word):
            saw = skip_next = True
        elif _REDIRECT_ATTACHED.match(word):
            saw = True
        else:
            clean.append(word)
    return clean, saw


def _parse_rm(args):
    """Return (recursive, force, paths, flags_are_harmless) for the words after `rm`."""
    recursive = force = False
    harmless = True
    paths = []
    options_ended = False
    for word in args:
        if options_ended or not word.startswith("-") or word == "-":
            paths.append(word)
        elif word == "--":
            options_ended = True
        elif word.startswith("--"):
            recursive = recursive or word == "--recursive"
            force = force or word == "--force"
            harmless = harmless and word in _LONG_FLAGS
        else:
            letters = word[1:]
            recursive = recursive or "r" in letters or "R" in letters
            force = force or "f" in letters
            harmless = harmless and set(letters) <= _FLAG_LETTERS
    return recursive, force, paths, harmless


def _tmp_root(raw):
    """Return the real path of $TMPDIR, or None when it is unset or too broad to trust."""
    if not raw or not os.path.isabs(raw):
        return None
    real = os.path.realpath(raw)
    home = os.path.realpath(os.path.expanduser("~"))
    if real in ("/", home) or real.count(os.sep) < 2 or home.startswith(real + os.sep):
        return None
    return real


def _inside(path, cwd, raw_tmpdir, root):
    """True when `path` resolves strictly inside the real $TMPDIR (root)."""
    for var in ("${TMPDIR}", "$TMPDIR"):
        if path == var or path.startswith(var + "/"):
            path = raw_tmpdir.rstrip("/") + path[len(var) :]
            break
    if not path or path.startswith("~") or _UNSAFE_CHARS.search(path):
        return False
    if not os.path.isabs(path):
        if not cwd:
            return False
        path = os.path.join(cwd, path)
    if ".." in path.split("/"):
        return False
    trimmed = path.rstrip("/") or "/"
    if path.endswith("/"):
        real = os.path.realpath(trimmed)  # a trailing slash follows a symlink
    else:
        real = os.path.join(os.path.realpath(os.path.dirname(trimmed)), os.path.basename(trimmed))
    return real.startswith(root + os.sep)


def _deny_by_text(command):
    """Fallback for text the scanner cannot parse: keep denying what plainly is `rm -rf`."""
    looks_like_rm = re.search(r"(^|[\s;&|(`])rm\s", command)
    recursive = re.search(r"\s-[A-Za-z]*[rR]|--recursive", command)
    force = re.search(r"\s-[A-Za-z]*f|--force", command)
    if looks_like_rm and recursive and force:
        return ("deny", _DENY_REASON)
    return None


def _root_ok(path, cwd, raw_tmpdir, root):
    """True when `path` is $TMPDIR itself or resolves inside it (a `find` search root)."""
    expanded = path
    for var in ("${TMPDIR}", "$TMPDIR"):
        if path == var or path.startswith(var + "/"):
            expanded = raw_tmpdir.rstrip("/") + path[len(var) :]
            break
    if os.path.isabs(expanded) and not _UNSAFE_CHARS.search(expanded):
        if ".." not in expanded.split("/") and os.path.realpath(expanded) == root:
            return True
    return _inside(path, cwd, raw_tmpdir, root)


def _find_hits(args):
    """True when a `find` call deletes: `-delete`, or `-exec rm -rf` and its variants."""
    if "-delete" in args:
        return True
    for words in _exec_commands(args):
        j = command_index(words)
        if j is None:
            continue
        if os.path.basename(words[j]) in _RM_NAMES:
            recursive, force, _paths, _harmless = _parse_rm(_strip_redirects(words[j + 1 :])[0])
            if recursive and force:
                return True
        elif _deny_by_text(" ".join(words[j:])):  # `-exec sh -c 'rm -rf {}'`
            return True
    return False


def _makes_directory(text: str) -> bool:
    """True when *text* is one plain `mktemp -d ...` command that really creates a directory."""
    try:
        found = walk(text)
    except ParseError:
        return False
    if len(found) != 1 or not found[0].argv or os.path.basename(found[0].argv[0]) != "mktemp":
        return False
    makes_dir = False
    for word in found[0].argv[1:]:
        if word == "--dry-run":
            return False
        if word == "--directory":
            makes_dir = True
        elif word.startswith("-") and not word.startswith("--") and word != "-":
            if "u" in word:  # `-u` only prints a name and creates nothing
                return False
            makes_dir = makes_dir or "d" in word
    return makes_dir


def _fresh_scratch(invocations: list[Invocation]) -> Callable[[int, int, str], bool]:
    """Return a check, `is_fresh(index, scope, name)`, for whether `$name` holds a new directory.

    It does when, in that scope, `name` is set exactly once, by a command that is nothing
    but `name=$(mktemp -d ...)`, earlier than the command asking, and nothing else in the
    scope can change it. A directory the same text just created cannot hold anything but
    what that text put in it, which is what makes `rm -rf "$name"` safe to leave alone.
    """
    made = {}
    writes = {}
    opaque = set()
    for index, inv in enumerate(invocations):
        for name, sub in inv.assignments:
            key = (inv.scope, name)
            writes[key] = writes.get(key, 0) + 1
            if sub is not None and _makes_directory(sub):
                made[key] = index
        i = command_index(inv.argv)
        if i is None:
            continue
        head = os.path.basename(inv.argv[i])
        rest = inv.argv[i + 1 :]
        if head in _OPAQUE:
            opaque.add(inv.scope)
        elif head in _SETS_VARS or (head == "printf" and "-v" in rest):
            for word in rest:
                if not word.startswith("-"):
                    key = (inv.scope, word.split("=", 1)[0])
                    writes[key] = writes.get(key, 0) + 1

    def is_fresh(index: int, scope: int, name: str) -> bool:
        start = made.get((scope, name))
        return (
            start is not None
            and start < index
            and writes[(scope, name)] == 1
            and scope not in opaque
        )

    return is_fresh


def _all_fresh(
    paths: list[str], is_fresh: Callable[[int, int, str], bool], index: int, scope: int
) -> bool:
    """True when every path is a bare `$NAME` or `${NAME}` that `is_fresh` accepts there.

    A suffix such as `$NAME/x` does not qualify: if `mktemp` failed, NAME is empty and
    `"$NAME"/*` would be `/*`.
    """
    if not paths:
        return False
    for path in paths:
        match = _FRESH_VAR.match(path)
        if not match or not is_fresh(index, scope, match.group(1) or match.group(2)):
            return False
    return True


def decide(command, cwd="", tmpdir=""):
    """Return ("allow" | "deny", reason), or None when the hook has no opinion."""
    try:
        invocations = walk(command)
    except ParseError:
        return _deny_by_text(command)
    # The hook cannot follow a `TMPDIR=` assignment or a `cd`, so after either it
    # trusts neither $TMPDIR nor the call's cwd.
    root = None if re.search(r"(?<![\w$])TMPDIR=", command) else _tmp_root(tmpdir)
    effective_cwd = cwd
    is_fresh = _fresh_scratch(invocations)
    saw_rm = False
    only_rm = True
    all_allowable = True
    for index, inv in enumerate(invocations):
        i = command_index(inv.argv)
        name = os.path.basename(inv.argv[i]) if i is not None else ""
        if name in _NAV:
            effective_cwd = ""
        if name == "find" and _find_hits(inv.argv[i + 1 :]):
            roots = _find_roots(inv.argv[i + 1 :])
            if root is None or not all(_root_ok(r, effective_cwd, tmpdir, root) for r in roots):
                return ("deny", _DENY_REASON)
        if name not in _RM_NAMES:
            only_rm = False
            continue
        saw_rm = True
        args, redirected = _strip_redirects(inv.argv[i + 1 :])
        recursive, force, paths, harmless = _parse_rm(args)
        inside = (
            root is not None
            and bool(paths)
            and all(_inside(p, effective_cwd, tmpdir, root) for p in paths)
        )
        if recursive and force and not inside and not _all_fresh(paths, is_fresh, index, inv.scope):
            return ("deny", _DENY_REASON)
        direct = (
            i == 0
            and not inv.sub_names
            and inv.pipeline == frozenset({os.path.basename(inv.argv[0])})
        )
        if not (direct and harmless and inside and not redirected):
            all_allowable = False
    if saw_rm and only_rm and all_allowable:
        return ("allow", _ALLOW_REASON)
    return None


def main():
    """Read the hook payload from stdin and print the decision. Fail toward no decision."""
    try:
        payload = load_payload(sys.stdin.read())
        if payload is None:
            return 0
        raw_cwd = payload.get("cwd")
        cwd = raw_cwd if isinstance(raw_cwd, str) else ""
        tmpdir = os.environ.get("TMPDIR", "")
        results = [decide(c, cwd, tmpdir) for c in read_commands(payload) if c.strip()]
    except Exception:
        return 0
    deny = next((r for r in results if r and r[0] == "deny"), None)
    if deny:
        print(json.dumps({"decision": "block", "reason": deny[1]}), file=sys.stderr)
        return 2
    if not results or not all(r and r[0] == "allow" for r in results):
        return 0
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": results[0][1],
        }
    }
    print(json.dumps(output))
    return 0


if __name__ == "__main__":
    sys.exit(main())
