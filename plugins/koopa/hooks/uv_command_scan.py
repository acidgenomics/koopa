#!/usr/bin/env python3
"""Decide whether a shell command line would run `uv` or `uvx`, and how.

Used by `block_uv.py`. The guard used to run one regex over the raw command
text, so it could not tell a command from text that merely mentions `uv`: a
heredoc body, a commit message, a `grep` pattern, or a comment all matched.
This scanner reads the command the way a shell does and answers the question
the guard cares about: would `uv` or `uvx` run, and could that run change
dependencies?

Verdicts (`uv_verdict`), the worst one across the whole command line wins:
    NONE     no uv/uvx command runs
    PROBE    every uv/uvx call is a known read-only probe
    CHANGE   at least one uv/uvx call may change dependencies, the
             environment, or the lockfile, or cannot be classified

Exit codes of `main` (a debugging aid; the guard imports the module):
    0   no uv/uvx command found
    10  a uv/uvx call that may change dependencies was found
    11  only read-only uv/uvx probes were found
    3   the command could not be parsed with confidence
    any other code (a crash exits 1) also means "could not decide".

Read-only probes are an allowlist; anything else is CHANGE:
    * `uv` or `uvx` with no arguments, `-h`/`--help`/`-V`/`--version` before
      the subcommand, and `uv help ...`
    * `uv <subcommand> --help` (or `-h`), except `uv run` and `uv tool`,
      whose trailing arguments belong to the launched program
    * `uv pip list|show|freeze|tree|check`, `uv python list|find|dir`,
      `uv tool list|dir`, `uv cache dir|size`, `uv self version`
    * `uv tree --frozen|--locked`, `uv lock --check|--locked|--check-exists|
      --dry-run`, and `uv version` with only `--short`/`--output-format`
    An unknown option before the subcommand, or a uv word fed by `xargs`, is
    CHANGE, because the real subcommand cannot be read.

Where uv is found:
    * any unquoted word that is `uv` or `uvx`, or a path ending in /uv or /uvx;
      the words after it are read as its arguments (this keeps
      `sudo -u x uv sync`, `timeout 5 uv sync`, and `python3 -m uv sync`
      classified)
    * a quoted command word (`'uv' sync`) and spellings like `u"v"`
    * anything inside `$(...)` or backticks, even inside double quotes
    * quoted strings passed to a shell or launcher (`bash -c "..."`, `ssh host
      '...'`, `eval "..."`, `tmux send-keys '...'`), scanned as shell code
    * heredoc bodies and piped text that reach a shell (`bash <<EOF`,
      `echo "..." | sh`)
    * code-shaped strings passed to an interpreter (`python3 -c 'os.system(
      "uv sync")'`, `["uv", "sync"]`); always CHANGE, since their arguments
      are not read

What does not count: `uv` inside quoted text given to a data command (`echo`,
`grep`, `git commit -m`, `gh pr create --body`), heredoc bodies fed to a
non-shell command, and comments.

Known limits, accepted because this guard is a speed bump and not a security
boundary: variable indirection (`$UV sync`), `$'...'` quoting, and text built
at run time and handed to a shell through process substitution are not
resolved. Anything that confuses the parser raises ParseError instead of
passing.

Compatible with Python 3.10 and newer, the floor for the deployed hooks.
"""

import re
import sys

UV_NAMES = frozenset({"uv", "uvx"})
MAX_DEPTH = 6

NONE = 0
PROBE = 1
CHANGE = 2

_HELP_FLAGS = frozenset({"-h", "--help", "-V", "--version"})
# Global options that take no value, and those that take one.
_GLOBAL_SWITCHES = frozenset(
    {
        "-n",
        "-q",
        "-v",
        "--managed-python",
        "--native-tls",
        "--no-cache",
        "--no-config",
        "--no-managed-python",
        "--no-progress",
        "--no-python-downloads",
        "--offline",
        "--quiet",
        "--verbose",
    }
)
_GLOBAL_VALUED = frozenset({"--cache-dir", "--color", "--config-file", "--directory", "--project"})
_REPEATED_SHORT = re.compile(r"^-[nqv]+$")
# Second-level verbs that only read, keyed by the first-level subcommand.
_READ_ONLY_VERBS = {
    "cache": frozenset({"dir", "size"}),
    "pip": frozenset({"check", "freeze", "list", "show", "tree"}),
    "python": frozenset({"dir", "find", "list"}),
    "self": frozenset({"version"}),
    "tool": frozenset({"dir", "list"}),
}
# Subcommands that only read when one of these flags is present.
_READ_ONLY_WITH = {
    "lock": frozenset({"--check", "--check-exists", "--dry-run", "--locked"}),
    "tree": frozenset({"--frozen", "--locked"}),
}
_VERSION_READ_ARGS = frozenset(
    {"--short", "--output-format", "--output-format=json", "--output-format=text", "json", "text"}
)
# Subcommands whose trailing arguments belong to a launched program.
_LAUNCHERS = frozenset({"run", "tool"})

# Commands whose quoted arguments, or piped and heredoc text, run as shell code.
CODE_CARRIERS = frozenset(
    {
        "ash",
        "at",
        "bash",
        "chroot",
        "csh",
        "dash",
        "docker",
        "eval",
        "fish",
        "flock",
        "kubectl",
        "ksh",
        "nsenter",
        "parallel",
        "podman",
        "pkexec",
        "runuser",
        "screen",
        "script",
        "sg",
        "sh",
        "source",
        "srun",
        "ssh",
        "su",
        "tcsh",
        "tmux",
        "watch",
        "zsh",
        ".",
    }
)

# Commands that forward to another command, so any later word may be the real one.
WRAPPERS = frozenset(
    {
        "builtin",
        "caffeinate",
        "command",
        "doas",
        "env",
        "exec",
        "flock",
        "ionice",
        "nice",
        "nohup",
        "setsid",
        "stdbuf",
        "sudo",
        "time",
        "timeout",
        "unbuffer",
        "xargs",
    }
)

# Commands that run code given as a string or on stdin.
INTERPRETERS = frozenset(
    {
        "awk",
        "bun",
        "deno",
        "gawk",
        "julia",
        "lua",
        "nawk",
        "node",
        "nodejs",
        "osascript",
        "perl",
        "php",
        "pypy",
        "pypy3",
        "Rscript",
        "ruby",
    }
)
_PYTHON = re.compile(r"^python[0-9.]*$")

# A string literal that starts with `uv <word>`, or an argv list that starts
# with "uv". Prose that merely quotes the bare word `uv` does not match.
CODE_SHAPED = re.compile(r"""["']\s*uvx?\s+[-A-Za-z]|\[\s*["']uvx?["']\s*,""")
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")


class ParseError(Exception):
    """The command could not be tokenized with confidence."""


class Word:
    """One shell word, kept as (kind, text) parts so quoting is not lost."""

    __slots__ = ("parts",)

    def __init__(self, parts):
        self.parts = parts

    @property
    def value(self):
        return "".join(text for _, text in self.parts)

    @property
    def all_bare(self):
        return all(kind == "bare" for kind, _ in self.parts)

    @property
    def has_bare(self):
        return any(kind == "bare" for kind, _ in self.parts)


class Cmd:
    """One simple command: its words, substitutions, and heredoc bodies."""

    __slots__ = ("group", "heredocs", "subs", "touched", "words")

    def __init__(self, group):
        self.words = []
        self.subs = []
        self.heredocs = []
        self.group = group
        self.touched = False


def _match_paren(text, open_idx):
    """Return the index of the `)` that closes the `(` at *open_idx*."""
    depth = 0
    i = open_idx
    n = len(text)
    while i < n:
        c = text[i]
        if c == "\\":
            i += 2
            continue
        if c == "'":
            end = text.find("'", i + 1)
            if end == -1:
                raise ParseError("unterminated single quote in substitution")
            i = end + 1
            continue
        if c == '"':
            i += 1
            while i < n and text[i] != '"':
                i += 2 if text[i] == "\\" else 1
            if i >= n:
                raise ParseError("unterminated double quote in substitution")
            i += 1
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ParseError("unterminated $(")


def _match_tick(text, open_idx):
    """Return the index of the backtick that closes the one at *open_idx*."""
    i = open_idx + 1
    n = len(text)
    while i < n:
        if text[i] == "\\":
            i += 2
            continue
        if text[i] == "`":
            return i
        i += 1
    raise ParseError("unterminated backtick")


def _extract_subs(text):
    """Return every `$(...)` and backtick body in *text* (an unquoted heredoc)."""
    found = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == "\\":
            i += 2
        elif c == "$" and text.startswith("(", i + 1):
            end = _match_paren(text, i + 1)
            found.append(text[i + 2 : end])
            i = end + 1
        elif c == "`":
            end = _match_tick(text, i)
            found.append(text[i + 1 : end])
            i = end + 1
        else:
            i += 1
    return found


class _Parser:
    """A small shell tokenizer: quotes, substitutions, heredocs, separators."""

    def __init__(self, text):
        self.text = text
        self.n = len(text)
        self.i = 0
        self.cmds = []
        self.group = 0
        self.cmd = Cmd(self.group)
        self.parts = []
        self.pending = []

    def add_bare(self, ch):
        if self.parts and self.parts[-1][0] == "bare":
            self.parts[-1] = ("bare", self.parts[-1][1] + ch)
        else:
            self.parts.append(("bare", ch))

    def end_word(self):
        if self.parts:
            self.cmd.words.append(Word(self.parts))
            self.parts = []

    def end_cmd(self, new_group):
        self.end_word()
        if self.cmd.words or self.cmd.subs or self.cmd.touched:
            self.cmds.append(self.cmd)
        if new_group:
            self.group += 1
        self.cmd = Cmd(self.group)

    def read_double_quoted(self):
        text = self.text
        i = self.i + 1
        buf = []
        while i < self.n and text[i] != '"':
            c = text[i]
            if c == "\\" and i + 1 < self.n:
                buf.append(text[i + 1])
                i += 2
            elif c == "$" and text.startswith("(", i + 1):
                end = _match_paren(text, i + 1)
                self.cmd.subs.append(text[i + 2 : end])
                buf.append(" ")
                i = end + 1
            elif c == "`":
                end = _match_tick(text, i)
                self.cmd.subs.append(text[i + 1 : end])
                buf.append(" ")
                i = end + 1
            else:
                buf.append(c)
                i += 1
        if i >= self.n:
            raise ParseError("unterminated double quote")
        self.parts.append(("dq", "".join(buf)))
        self.i = i + 1

    def read_heredoc_op(self):
        text = self.text
        j = self.i + 2
        strip = False
        if j < self.n and text[j] == "-":
            strip = True
            j += 1
        while j < self.n and text[j] in " \t":
            j += 1
        delim = []
        expands = True
        while j < self.n and text[j] not in " \t\n;&|<>()":
            ch = text[j]
            if ch in "'\"":
                end = text.find(ch, j + 1)
                if end == -1:
                    raise ParseError("unterminated heredoc delimiter quote")
                delim.append(text[j + 1 : end])
                expands = False
                j = end + 1
            elif ch == "\\":
                if j + 1 < self.n:
                    delim.append(text[j + 1])
                    expands = False
                j += 2
            else:
                delim.append(ch)
                j += 1
        name = "".join(delim)
        if not name:
            raise ParseError("heredoc with no delimiter")
        self.end_word()
        self.cmd.touched = True
        self.pending.append((self.cmd, name, strip, expands))
        self.i = j

    def read_heredoc_bodies(self):
        """Consume the body of every heredoc queued on the line just ended."""
        text = self.text
        for owner, name, strip, expands in self.pending:
            lines = []
            while True:
                if self.i >= self.n:
                    # No terminator. In a batched call this would swallow the
                    # next command as data, so refuse to guess.
                    raise ParseError("unterminated heredoc")
                end = text.find("\n", self.i)
                line = text[self.i :] if end == -1 else text[self.i : end]
                self.i = self.n if end == -1 else end + 1
                if (line.lstrip("\t") if strip else line) == name:
                    break
                lines.append(line)
            owner.heredocs.append(("\n".join(lines), expands))
        self.pending = []

    def parse(self):
        text = self.text
        while self.i < self.n:
            c = text[self.i]
            if c == "\\":
                if self.i + 1 < self.n and text[self.i + 1] != "\n":
                    self.add_bare(text[self.i + 1])
                self.i += 2
            elif c == "'":
                end = text.find("'", self.i + 1)
                if end == -1:
                    raise ParseError("unterminated single quote")
                self.parts.append(("sq", text[self.i + 1 : end]))
                self.i = end + 1
            elif c == '"':
                self.read_double_quoted()
            elif c == "$" and text.startswith("(", self.i + 1):
                end = _match_paren(text, self.i + 1)
                self.cmd.subs.append(text[self.i + 2 : end])
                self.add_bare("$")
                self.i = end + 1
            elif c == "`":
                end = _match_tick(text, self.i)
                self.cmd.subs.append(text[self.i + 1 : end])
                self.add_bare("`")
                self.i = end + 1
            elif c == "#" and not self.parts:
                end = text.find("\n", self.i)
                self.i = self.n if end == -1 else end
            elif c in " \t":
                self.end_word()
                self.i += 1
            elif c == "\n":
                self.end_cmd(True)
                self.i += 1
                if self.pending:
                    self.read_heredoc_bodies()
            elif c == "<" and text.startswith("<<", self.i) and not text.startswith("<<<", self.i):
                self.read_heredoc_op()
            elif c in ";|&":
                if c == "&" and self.i > 0 and text[self.i - 1] in "<>":
                    self.add_bare(c)  # `2>&1`
                    self.i += 1
                elif c == "&" and text.startswith("&>", self.i):
                    self.add_bare(c)  # `&> file`
                    self.i += 1
                elif c == "|" and not text.startswith("||", self.i):
                    self.end_cmd(False)  # a pipe keeps the same pipeline group
                    self.i += 2 if text.startswith("|&", self.i) else 1
                else:
                    self.end_cmd(True)
                    while self.i < self.n and text[self.i] in ";|&":
                        self.i += 1
            elif c in "()":
                self.end_cmd(True)
                self.i += 1
            else:
                self.add_bare(c)
                self.i += 1
        self.end_cmd(True)
        if self.pending:
            raise ParseError("heredoc operator with no body")
        return self.cmds


def _base(value):
    return value.rsplit("/", 1)[-1]


def _command_words(cmd):
    """The command's words after any leading `NAME=value` assignments."""
    words = cmd.words
    k = 0
    while k < len(words) and words[k].all_bare and ASSIGNMENT.match(words[k].value):
        k += 1
    return words[k:]


def _names(cmd):
    """Basenames that decide what this command is: its head, plus the words
    after a wrapper such as `sudo` or `env`, which forward to another command.
    """
    words = _command_words(cmd)
    if not words:
        return set()
    head = _base(words[0].value)
    names = {head}
    if head in WRAPPERS:
        for word in words[1:]:
            if word.all_bare:
                names.add(_base(word.value))
    return names


def _is_interpreter(name):
    return name in INTERPRETERS or bool(_PYTHON.match(name))


def classify_uv(name, args):
    """Return PROBE when `uv` or `uvx` with *args* only reads, else CHANGE."""
    if name == "uvx":
        return PROBE if not args or args[0] in _HELP_FLAGS else CHANGE
    i = 0
    while i < len(args):
        arg = args[i]
        if arg in _HELP_FLAGS:
            return PROBE
        if arg in _GLOBAL_SWITCHES or _REPEATED_SHORT.match(arg):
            i += 1
        elif arg in _GLOBAL_VALUED:
            i += 2
        elif arg.startswith("--") and arg.split("=", 1)[0] in _GLOBAL_VALUED:
            i += 1
        elif arg.startswith("-"):
            return CHANGE  # an unknown option hides where the subcommand starts
        else:
            break
    rest = args[i:]
    if not rest:
        return PROBE  # bare `uv` prints its help
    sub, tail = rest[0], rest[1:]
    if sub == "help":
        return PROBE
    if sub not in _LAUNCHERS:
        own = tail[: tail.index("--")] if "--" in tail else tail
        if any(arg in ("-h", "--help") for arg in own):
            return PROBE
    verbs = _READ_ONLY_VERBS.get(sub)
    if verbs is not None:
        return PROBE if tail and tail[0] in verbs else CHANGE
    flags = _READ_ONLY_WITH.get(sub)
    if flags is not None:
        return PROBE if any(arg in flags for arg in tail) else CHANGE
    if sub == "version":
        return PROBE if all(arg in _VERSION_READ_ARGS for arg in tail) else CHANGE
    return CHANGE


def _cmd_verdict(cmd, carrier, interp, depth):
    """The worst verdict for one simple command; stops early at CHANGE."""
    words = cmd.words
    start = len(words) - len(_command_words(cmd))
    verdict = NONE
    for idx, word in enumerate(words):
        name = _base(word.value)
        if name not in UV_NAMES:
            continue
        # Unquoted (or a mixed spelling such as u"v"), a fully quoted command
        # word ('uv' sync), or any spelling handed to a shell carrier.
        if not (word.has_bare or idx == start or carrier):
            continue
        if any(_base(w.value) == "xargs" for w in words[:idx]):
            return CHANGE  # xargs appends arguments the scanner cannot see
        verdict = max(verdict, classify_uv(name, [w.value for w in words[idx + 1 :]]))
        if verdict == CHANGE:
            return CHANGE
    for sub in cmd.subs:
        verdict = max(verdict, _scan(sub, depth + 1))
        if verdict == CHANGE:
            return CHANGE
    for word in words:
        for kind, part in word.parts:
            if kind == "bare":
                continue
            if interp and CODE_SHAPED.search(part):
                return CHANGE
            if carrier:
                verdict = max(verdict, _scan(part, depth + 1))
                if verdict == CHANGE:
                    return CHANGE
    for body, expands in cmd.heredocs:
        if interp and CODE_SHAPED.search(body):
            return CHANGE
        if carrier:
            verdict = max(verdict, _scan(body, depth + 1))
        elif expands:
            for sub in _extract_subs(body):
                verdict = max(verdict, _scan(sub, depth + 1))
        if verdict == CHANGE:
            return CHANGE
    return verdict


def _scan(text, depth):
    if depth > MAX_DEPTH:
        raise ParseError("commands nested too deeply")
    cmds = _Parser(text).parse()
    by_group = {}
    for cmd in cmds:
        by_group.setdefault(cmd.group, []).append(cmd)
    flags = {}
    for group, members in by_group.items():
        names = set()
        for member in members:
            names |= _names(member)
        flags[group] = (
            bool(names & CODE_CARRIERS),
            any(_is_interpreter(name) for name in names),
        )
    verdict = NONE
    for cmd in cmds:
        carrier, interp = flags[cmd.group]
        verdict = max(verdict, _cmd_verdict(cmd, carrier, interp, depth))
        if verdict == CHANGE:
            return CHANGE
    return verdict


def uv_verdict(command):
    """Return NONE, PROBE, or CHANGE for *command*. Raise ParseError if unsure."""
    return _scan(command, 0)


def runs_uv(command):
    """Return True if *command* would run uv or uvx at all. Raise ParseError if unsure."""
    return uv_verdict(command) != NONE


def main():
    text = sys.stdin.read()
    try:
        verdict = uv_verdict(text)
    except Exception:  # ParseError, RecursionError, anything unexpected: cannot decide
        return 3
    return {NONE: 0, PROBE: 11, CHANGE: 10}[verdict]


if __name__ == "__main__":
    sys.exit(main())
