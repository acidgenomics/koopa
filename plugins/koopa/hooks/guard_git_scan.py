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
    * `git checkout -- .` and `git checkout .`
    * `git branch -D`
    * `git push origin main` or `master` (also `HEAD:main`, `refs/heads/main`), unless
      an earlier `cd` (or `git -C`) in the same command line names a different git
      repository. The target is read as literal text and never evaluated. Any shell
      syntax in it (expansion, escapes, globs) counts as "the current repository",
      so the push is blocked.
    * `git push --all`, `--branches`, `--mirror`, a bare `:` refspec, or a glob
      refspec to `origin` (or no remote), since each can update `main` without naming it.

    Rules for a checkout shared by several agent sessions, where one session's
    command can capture or discard another's uncommitted work:
    * `git add -A`, `--all`, `-u`, `--update`, `git add .`, `git add :/`
    * `git commit -a` (also bundled, such as `-am`)
    * a bare `git stash`, `git stash push` with no pathspec, `git stash save`, and
      `git stash pop`, `drop` or `clear`. `git stash push -- <path>` is allowed.
    * `git restore` with a `.` or `:/` pathspec
    * `git worktree remove` and `git worktree prune`

A repository can switch a rule off by its name, for example in a checkout whose own
workflow pushes to `main`: `git config --add koopa.allowGitRules "push origin
main/master"`. Only the user sets this; the value is read from the project's git config.

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
_PROTECTED = re.compile(r"(^|:)(refs/heads/)?(main|master)$")
_ALL_BRANCH_FLAGS = frozenset({"--all", "--branches", "--mirror"})
_WHOLE_TREE = frozenset({".", ":/"})
_STASH_DESTROY = frozenset({"pop", "drop", "clear"})
_STASH_VALUE_OPTS = frozenset({"-m", "--message", "--pathspec-from-file"})


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


def _stash_rule(args: list[str]) -> str | None:
    """Name the stash rule *args* (after `stash`) matches: a whole-tree stash or a pop/drop."""
    words: list[str] = []
    skip = False
    for arg in args:
        if skip:
            skip = False
        elif arg in _STASH_VALUE_OPTS:
            skip = True
        elif arg == "--" or not arg.startswith("-"):
            words.append(arg)
    if words and words[0] in _STASH_DESTROY:
        return f"stash {words[0]}"
    if not words or words[0] == "save" or (words[0] == "push" and words[1:] in ([], ["--"])):
        return "stash"
    return None


_SHARED_CHECKOUT_NAMES = {
    "add": "add -A",
    "commit": "commit -a",
    "restore": "restore .",
    "checkout": "checkout .",
}


def _shared_checkout_rule(sub: str, args: list[str]) -> str | None:
    """Name the rule for a command that captures or discards other sessions' work."""
    positional = _positionals(args)
    whole_tree = bool(_WHOLE_TREE.intersection(positional))
    matched = {
        "add": _short(args, "A")
        or _short(args, "u")
        or bool({"--all", "--update"}.intersection(args))
        or whole_tree,
        "commit": _short(args, "a") or "--all" in args,
        "restore": whole_tree,
        "checkout": "." in positional,
    }
    if matched.get(sub):
        return _SHARED_CHECKOUT_NAMES[sub]
    if sub == "stash":
        return _stash_rule(args)
    if sub == "worktree" and positional[:1] in (["remove"], ["prune"]):
        return f"worktree {positional[0]}"
    return None


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
    return _shared_checkout_rule(sub, args)


def _push_main_rule(args: list[str]) -> str | None:
    """Name the rule for a push to origin that updates main or master, named or not."""
    positional = _positionals(args)
    if positional and positional[0] != "origin":
        return None
    refspecs = positional[1:]
    if any(_PROTECTED.search(ref) for ref in refspecs):
        return "push origin main/master"
    if _ALL_BRANCH_FLAGS.intersection(args) or any(ref == ":" or "*" in ref for ref in refspecs):
        return "push --all"
    return None


def _allowed_rules(project_dir: str) -> frozenset[str]:
    """Rule names the project's git config switches off (`koopa.allowGitRules`)."""
    try:
        result = subprocess.run(
            ["git", "-C", project_dir, "config", "--get-all", "koopa.allowGitRules"],
            capture_output=True,
            text=True,
            check=False,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return frozenset()
    return frozenset(line.strip() for line in result.stdout.splitlines() if line.strip())


def find_destructive(command: str) -> str | None:
    """Return the name of the first destructive git rule *command* would trigger."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    last_cd = None
    allowed: frozenset[str] | None = None
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
        if rule is None and sub == "push":
            rule = _push_main_rule(args)
            if rule and _different_repo(c_path or last_cd, project_dir):
                rule = None
        if rule is None:
            continue
        if allowed is None:
            allowed = _allowed_rules(project_dir)
        if rule not in allowed:
            return rule
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


def project_pushes(command: str, project_dir: str) -> list[list[str]]:
    """Return the arguments of every `git push` *command* runs in the project's own repository.

    A push after a `cd` or `git -C` into a different repository is left out, with the same
    literal, never-evaluated reading of the target that `find_destructive` uses.
    """
    pushes: list[list[str]] = []
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
        if sub == "push" and not _different_repo(c_path or last_cd, project_dir):
            pushes.append(args)
    return pushes


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
