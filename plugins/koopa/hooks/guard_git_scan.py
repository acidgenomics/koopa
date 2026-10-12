#!/usr/bin/env python3
"""Decide whether a shell command line would run a destructive git command.

Used by `block-destructive-git.sh` and `audit-secrets-before-push.sh`. Those guards
used to match phrases such as `reset --hard` anywhere in the raw command text, so
they also blocked a command that only mentioned one: a `grep` pattern, a commit
message, a heredoc body holding documentation. This scanner reads the command the
way a shell does and asks about git commands that would run.

Usage: `guard_git_scan.py destructive` or `guard_git_scan.py push`, with the command
on stdin.

Exit codes:
    0   nothing found
    10  found; for `destructive` the rule name is printed on stdout
    3   the command could not be parsed with confidence
    any other code (a crash, a missing interpreter) also means "could not decide"

On anything other than 0 or 10 the caller falls back to its original text patterns.

`destructive` finds:
    * `git reset --hard`
    * `git clean` with force and directories (`-fd`, `-df`, `-f -d`, `--force -d`)
    * `git push` with a force flag (`-f`, `--force`, `--force-with-lease`) or a
      `+refspec`
    * `git rm` with recursive and force (`-rf`, `-fr`, `-r -f`)
    * `git checkout -- .`
    * `git branch -D`
    * `git push origin main` or `master`, unless an earlier `cd` (or `git -C`) in
      the same command line names a different git repository. The target is read
      as literal text and never evaluated. Any shell syntax in it (expansion,
      escapes, globs) counts as "the current repository", so the push is blocked.

`push` finds any `git push`.

Known limits: a `cd` inside a subshell is treated like a `cd` in the main shell, and
variable indirection (`$CMD push`) is not resolved.
"""

import os
import re
import subprocess
import sys
from pathlib import Path

from shell_command_scan import base, command_index, walk

EXIT_CLEAN = 0
EXIT_FOUND = 10
EXIT_UNSURE = 3

# git options that take a separate value before the subcommand.
_VALUE_OPTS = frozenset({"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"})
_UNSAFE = re.compile(r"[^A-Za-z0-9_./@%+=:,~ -]")
_PROTECTED = re.compile(r"(^|:)(main|master)$")


def _git_parts(argv: list[str]) -> tuple[str | None, list[str], str | None]:
    """Split `git [global options] <subcommand> <args>` into its parts.

    Returns (subcommand, args after it, the last `-C` path or None).
    """
    c_path = None
    i = 1
    while i < len(argv):
        word = argv[i]
        if word in _VALUE_OPTS:
            if word == "-C" and i + 1 < len(argv):
                c_path = argv[i + 1]
            i += 2
        elif word.startswith("-"):
            i += 1
        else:
            return word, argv[i + 1 :], c_path
    return None, [], c_path


def _short(args: list[str], letter: str) -> bool:
    """True if a short-option cluster such as `-fd` contains *letter*."""
    return any(a.startswith("-") and not a.startswith("--") and letter in a[1:] for a in args)


def _positionals(args: list[str]) -> list[str]:
    return [a for a in args if not a.startswith("-")]


def _toplevel(base_dir: str, target: str | None) -> str:
    """The git root for *target* (relative to *base_dir*), or "" if it is not a repo."""
    cmd = ["git", "-C", base_dir]
    if target:
        cmd += ["-C", target]
    cmd += ["rev-parse", "--show-toplevel"]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=False, timeout=5)
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def _different_repo(target: str | None, project_dir: str) -> bool:
    """True if *target* is a git repository other than the project's own.

    The target is plain text. Anything with shell syntax counts as the project.
    """
    if not target or target == "-":
        return False
    if target == "~" or target.startswith("~/"):
        target = str(Path.home()) + target[1:]
    if _UNSAFE.search(target):
        return False
    here = _toplevel(project_dir, None)
    there = _toplevel(project_dir, target)
    return bool(there) and there != here


def _rule(sub: str, args: list[str]) -> str | None:
    """Name the always-blocked rule that *sub* with *args* matches, if any."""
    if sub == "reset" and "--hard" in args:
        return "reset --hard"
    if sub == "clean" and (_short(args, "f") or "--force" in args) and _short(args, "d"):
        return "clean -fd"
    if sub == "push":
        forced = _short(args, "f") or any(a.startswith("--force") for a in args)
        if forced or any(a.startswith("+") for a in _positionals(args)):
            return "push --force"
    if sub == "rm":
        recursive = _short(args, "r") or _short(args, "R") or "--recursive" in args
        if recursive and (_short(args, "f") or "--force" in args):
            return "git rm -rf"
    if sub == "checkout" and "--" in args and "." in args[args.index("--") + 1 :]:
        return "checkout -- ."
    if sub == "branch" and _short(args, "D"):
        return "branch -D"
    return None


def find_destructive(command: str) -> str | None:
    """Return the name of the first destructive git rule *command* would trigger."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    last_cd = None
    for invocation in walk(command):
        start = command_index(invocation.argv)
        if start is None:
            continue
        argv = invocation.argv[start:]
        name = base(argv[0])
        if name == "cd":
            rest = [a for a in argv[1:] if not a.startswith("-") or a == "-"]
            last_cd = rest[0] if rest else None
            continue
        if name != "git":
            continue
        sub, args, c_path = _git_parts(argv)
        if sub is None:
            continue
        rule = _rule(sub, args)
        if rule:
            return rule
        if sub == "push":
            positional = _positionals(args)
            if (
                len(positional) >= 2
                and positional[0] == "origin"
                and _PROTECTED.search(positional[1])
                and not _different_repo(c_path or last_cd, project_dir)
            ):
                return "push origin main/master"
    return None


def runs_git_push(command: str) -> bool:
    """True if *command* would run `git push`."""
    for invocation in walk(command):
        start = command_index(invocation.argv)
        if start is None or base(invocation.argv[start]) != "git":
            continue
        if _git_parts(invocation.argv[start:])[0] == "push":
            return True
    return False


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    text = sys.stdin.read()
    try:
        if mode == "destructive":
            rule = find_destructive(text)
            if rule:
                print(rule)
                return EXIT_FOUND
            return EXIT_CLEAN
        if mode == "push":
            return EXIT_FOUND if runs_git_push(text) else EXIT_CLEAN
    except Exception:  # ParseError, RecursionError, anything unexpected
        return EXIT_UNSURE
    return EXIT_UNSURE


if __name__ == "__main__":
    sys.exit(main())
