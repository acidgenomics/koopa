#!/usr/bin/env python3
"""PreToolUse hook: keep scratch files out of /tmp. Use `mktemp`, which honors $TMPDIR.

Scratch files in /tmp are shared with every user and process on the machine, they
survive the session, and on macOS they sit outside the per-user $TMPDIR that
`mktemp` uses. This hook denies tool calls that would create or write to /tmp,
/var/tmp, or /dev/shm (including their /private/... spellings and symlinks to
them), and tells the model to run `mktemp -d` and use that path instead.

Denied:

* Write, Edit, MultiEdit, NotebookEdit, and Copilot's `create` and `apply_patch`
  whose target path is under those roots.
* Bash that writes there: a redirect (`> /tmp/x`, `>| /tmp/x`, `2>/tmp/e`, `&>`),
  `tee`, `touch`, `mkdir`, `mktemp` given a /tmp path or run with `TMPDIR=/tmp`,
  `curl -o`, `dd of=`, `cd /tmp`, a `cp`, `mv`, `install`, `ln`, or `rsync` whose
  destination is there, `tar` that creates an archive there or extracts with `-C`,
  and interpreter code (`python3 -c`, a heredoc, a `poetry run python -c`) that
  names a /tmp path next to a write.
* A `NAME=/tmp/...` assignment is followed through `$NAME` and `${NAME}` in the
  same command.

Not decided (the normal permission flow runs): read-only commands (`ls`, `cat`,
`grep`, `sort`, `awk`, `sed` without `-i`, `tar -t`, read-only `git` subcommands,
...), running a script that lives in /tmp, a /tmp path used only as a `cp` or `mv`
source, and `rm` or `rmdir`, so legacy files can still be cleaned up with a prompt.

This is a best-effort check on the command text. A path that the command builds at
run time (`cd $(dirname ...)`, a variable set in an earlier call) is not seen.

The guard is inactive when $TMPDIR is unset or is itself under one of those roots,
because `mktemp` then produces /tmp paths and a guard would block everything.

Deployed from the public dotfiles tree to `~/.agents/hooks/guard_tmp.py`.
Needs `hook_adapter.py` and `shell_command_scan.py` beside it, and Python 3.10
or newer.
"""

import json
import os
import re
import sys

from hook_adapter import HookInputError, load_payload, read_commands, read_targets
from shell_command_scan import ParseError, command_index, walk

_ROOTS = ("/tmp", "/private/tmp", "/var/tmp", "/private/var/tmp", "/dev/shm")
_DENIED_ROOTS = tuple(sorted(set(_ROOTS) | {os.path.realpath(root) for root in _ROOTS}))
_FILE_TOOLS = frozenset(
    {"write", "edit", "multiedit", "notebookedit", "create", "apply_patch", "str_replace_editor"}
)
_RUNNERS = frozenset({"poetry", "pixi", "conda", "mamba", "micromamba", "pipenv", "uv", "hatch"})
_SHELL_LIKE = frozenset(
    {"bash", "sh", "zsh", "dash", "ksh", "source", ".", "node", "perl", "ruby", "php", "lua"}
)
_READ_ONLY = frozenset(
    {
        "ls", "cat", "head", "tail", "less", "more", "grep", "egrep", "fgrep", "rg", "wc",
        "file", "stat", "du", "diff", "cmp", "readlink", "realpath", "test", "[", "nl", "od",
        "hexdump", "strings", "jq", "md5", "md5sum", "shasum", "sha256sum", "echo", "printf",
        "awk", "gawk", "cut", "uniq", "xxd", "zcat", "column", "open", "basename", "dirname",
        "tree", "rm", "rmdir",
    }
)  # fmt: skip
_GIT_READ = frozenset(
    {
        "log", "status", "diff", "show", "blame", "ls-files", "ls-tree", "rev-parse", "rev-list",
        "describe", "branch", "tag", "remote", "config", "shortlog", "grep", "cat-file",
    }
)  # fmt: skip
_FIND_WRITES = frozenset({"-delete", "-exec", "-execdir", "-ok", "-fprint", "-fprintf", "-fls"})
_DEST_LAST = frozenset({"cp", "mv", "install", "ln", "rsync", "scp"})
_NAV = frozenset({"cd", "pushd"})
_REDIRECT_BARE = re.compile(r"^(?:\d*|&)(?:>>?|>\|)$")
_REDIRECT_ATTACHED = re.compile(r"^(?:\d*|&)(?:>>?|>\|)(.+)$")
_INPUT_BARE = re.compile(r"^\d*<$")  # `< file`: reads, so it is dropped with its target
_INPUT_ATTACHED = re.compile(r"^\d*<[^<].*$")  # `<file`
# `>| file`: the scanner reads the `|` as a pipe, so find this form in the raw text.
_CLOBBER = re.compile(r">\|\s*([\"']?)([^\s\"';&|)]+)\1")
_ASSIGN = re.compile(r"(?<![\w$./-])([A-Za-z_]\w*)=([\"']?)(/[^\s\"';&|)]*)\2")
_PY_COMMENT = re.compile(r"(?m)(?:^|(?<=\s))#.*$")
_PAYLOAD_PATH = re.compile(
    r"(?<![\w$/.-])(?:/private/var/tmp|/private/tmp|/var/tmp|/tmp|/dev/shm)(?=/|[\"'\s)\]]|$)"
)
_WRITE_MODE = r"[\"'][rwabxt+]*[wax+][rwabxt+]*[\"']"
_WRITE_HINT = re.compile(
    r"open\(\s*[^,()]+,\s*" + _WRITE_MODE
    + r"|mode\s*=\s*" + _WRITE_MODE
    + r"|\.open\(\s*" + _WRITE_MODE
    + r"|write|mkdir|makedirs|mkstemp|Temporary|to_csv|to_parquet|to_json|to_excel|savefig"
    + r"|\.save\(|dump\(|copy|move|touch|symlink|os\.rename|os\.replace|os\.link"
    + r"|urlretrieve|extractall|extract\("
)  # fmt: skip

REASON = (
    "Do not use /tmp, /var/tmp, or /dev/shm for scratch files. Run `mktemp -d` (it honors "
    "$TMPDIR), use that path, and delete only what you created."
)


def _tmp_real(raw):
    """Return the real $TMPDIR when the guard should run, else None."""
    if not raw or not os.path.isabs(raw):
        return None
    real = os.path.realpath(raw)
    for root in _DENIED_ROOTS:
        if real == root or real.startswith(root + os.sep):
            return None
    return real


def _is_denied(path, tmp_real):
    """True when an absolute `path` resolves under a denied root and not under $TMPDIR."""
    if not path or "$" in path or "\n" in path or not os.path.isabs(path):
        return False
    real = os.path.realpath(os.path.normpath(path))
    if real == tmp_real or real.startswith(tmp_real + os.sep):
        return False
    return any(real == root or real.startswith(root + os.sep) for root in _DENIED_ROOTS)


def _split_redirects(argv):
    """Return (words without redirects, write-redirect targets)."""
    words = []
    targets = []
    expect_target = False
    skip_input = False
    for word in argv:
        if skip_input:
            skip_input = False
        elif expect_target:
            targets.append(word)
            expect_target = False
        elif _REDIRECT_BARE.match(word):
            expect_target = True
        elif _INPUT_BARE.match(word):
            skip_input = True
        elif _INPUT_ATTACHED.match(word):
            continue
        else:
            match = _REDIRECT_ATTACHED.match(word)
            if match and not match.group(1).startswith("&"):
                targets.append(match.group(1))
            elif not match:
                words.append(word)
    return words, targets


def _destinations(args):
    """The words a cp/mv/install/ln/rsync/scp call writes to."""
    plain = []
    target = None
    expect = False
    for word in args:
        if expect:
            target, expect = word, False
        elif word in ("-t", "--target-directory"):
            expect = True
        elif word.startswith("--target-directory="):
            target = word.split("=", 1)[1]
        elif not (word.startswith("-") and word != "-"):
            plain.append(word)
    return [target] if target is not None else plain[-1:]


def _values(word):
    """A word, plus the value inside `key=value` (`of=/tmp/x`) or `-o/tmp/x`."""
    values = [word]
    if "=" in word and not word.startswith("/"):
        values.append(word.split("=", 1)[1])
    if re.match(r"^-[A-Za-z]/", word):
        values.append(word[2:])
    return values


def _option_values(args, short, long):
    """Values given to one option: `-C dir`, `-Cdir`, `--directory dir`, `--directory=dir`."""
    found = []
    for i, word in enumerate(args):
        if word in (short, long) and i + 1 < len(args):
            found.append(args[i + 1])
        elif word.startswith(short) and len(word) > len(short) and not word.startswith("--"):
            found.append(word[len(short) :])
        elif word.startswith(long + "="):
            found.append(word.split("=", 1)[1])
    return found


def _tar_candidates(args):
    """Paths a `tar` call writes: the archive when it creates one, and `-C` directories."""
    clusters = [a.lstrip("-") for a in args if re.match(r"^-[A-Za-z]+$", a)]
    if args and re.match(r"^[A-Za-z]+$", args[0]):
        clusters.append(args[0])  # legacy `tar czf out.tgz dir`
    create = "--create" in args or any("c" in cluster for cluster in clusters)
    return (list(args) if create else []) + _option_values(args, "-C", "--directory")


def _git_candidates(args):
    """Arguments of a `git` call, or none for a read-only subcommand."""
    i = 0
    while i < len(args) and args[i].startswith("-"):
        i += 2 if args[i] in ("-C", "-c") else 1
    if i < len(args) and args[i] in _GIT_READ:
        return []
    return list(args)


def _candidates(name, args):
    """The words of a call that may be a path it writes to."""
    if name in _DEST_LAST:
        return _destinations(args)
    if name == "find":
        return list(args) if _FIND_WRITES.intersection(args) else []
    if name == "tar":
        return _tar_candidates(args)
    if name == "unzip":
        return _option_values(args, "-d", "--directory")
    if name == "git":
        return _git_candidates(args)
    if name == "sed":
        in_place = any(a == "--in-place" or re.match(r"^-[A-Za-z]*i", a) for a in args)
        return list(args) if in_place else []
    if name == "sort":
        writes = any(a.startswith("-o") or a.startswith("--output") for a in args)
        return list(args) if writes else []
    if name in _READ_ONLY:
        return []
    if name in _SHELL_LIKE or re.match(r"^python[0-9.]*$", name):
        rest = list(args)
        for i, word in enumerate(rest):
            if not word.startswith("-"):
                del rest[i]  # the script being run is read, not written
                break
        return rest
    return list(args)


def _expand_assignments(command):
    """Replace `$NAME` and `${NAME}` with the value of a `NAME=/abs/path` in the command."""
    values = {m.group(1): m.group(3) for m in _ASSIGN.finditer(command)}
    for name in sorted(values, key=len, reverse=True):
        pattern = r"\$\{%s\}|\$%s(?!\w)" % (name, name)
        command = re.sub(pattern, lambda _m, v=values[name]: v, command)
    return command, values


def _check_invocation(inv, tmp_real):
    words, targets = _split_redirects(inv.argv)
    if any(_is_denied(t, tmp_real) for t in targets):
        return REASON
    i = command_index(words)
    name = os.path.basename(words[i]) if i is not None else ""
    payloads = list(inv.payloads)
    if name in _RUNNERS:  # `poetry run python -c "..."`: the code is a quoted word
        payloads.extend(word for word in words if re.search(r"\s", word))
    for payload in payloads:
        code = _PY_COMMENT.sub("", payload)
        if _PAYLOAD_PATH.search(code) and _WRITE_HINT.search(code):
            return REASON
    if i is None:
        return None
    candidates = _candidates(name, words[i + 1 :])
    if name not in _NAV and name not in _DEST_LAST and name != "find":
        candidates = [value for word in candidates for value in _values(word)]
    return REASON if any(_is_denied(c, tmp_real) for c in candidates) else None


def decide_bash(command, tmpdir=""):
    """Return the deny reason for a Bash command, or None."""
    tmp_real = _tmp_real(tmpdir)
    if tmp_real is None:
        return None
    command, assigned = _expand_assignments(command)
    if _is_denied(assigned.get("TMPDIR", ""), tmp_real):
        return REASON
    if any(_is_denied(m.group(2), tmp_real) for m in _CLOBBER.finditer(command)):
        return REASON
    try:
        invocations = walk(command)
    except ParseError:
        return None
    for inv in invocations:
        reason = _check_invocation(inv, tmp_real)
        if reason:
            return reason
    return None


def decide_file(path, tmpdir=""):
    """Return the deny reason for a file-tool target path, or None."""
    tmp_real = _tmp_real(tmpdir)
    if tmp_real is None:
        return None
    return REASON if _is_denied(path, tmp_real) else None


def _file_paths(payload):
    """Target paths of the file-writing tool calls in a Claude Code or Copilot payload."""
    cwd = payload.get("cwd")
    if "tool_input" in payload:
        entries = [(payload.get("tool_name") or payload.get("toolName"), payload["tool_input"])]
    else:
        calls = payload.get("toolCalls")
        entries = [
            (call.get("toolName") or call.get("name"), call.get("args"))
            for call in (calls if isinstance(calls, list) else [])
            if isinstance(call, dict)
        ]
    paths = []
    for tool, tool_input in entries:
        if not isinstance(tool, str) or tool.lower() not in _FILE_TOOLS:
            continue
        if isinstance(tool_input, dict) and isinstance(tool_input.get("notebook_path"), str):
            paths.append(tool_input["notebook_path"])
        try:
            sub = {"tool_input": tool_input, "cwd": cwd if isinstance(cwd, str) else None}
            paths.extend(target.path for target in read_targets(sub))
        except HookInputError:
            continue
    return paths


def main():
    """Read the hook payload from stdin; exit 2 with a reason to deny. Fail toward no decision."""
    try:
        payload = load_payload(sys.stdin.read())
        if payload is None:
            return 0
        tmpdir = os.environ.get("TMPDIR", "")
        reason = None
        for command in read_commands(payload):
            reason = reason or decide_bash(command, tmpdir)
        for path in _file_paths(payload):
            reason = reason or decide_file(path, tmpdir)
    except Exception:
        return 0
    if reason:
        print(json.dumps({"decision": "block", "reason": reason}), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
