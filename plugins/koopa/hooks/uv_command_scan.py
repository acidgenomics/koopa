#!/usr/bin/env python3
"""Decide whether a shell command line would run `uv` or `uvx`.

Used by `block-uv.sh`. The guard used to run one regex over the raw command
text, so it could not tell a command from text that merely mentions `uv`: a
heredoc body, a commit message, a `grep` pattern, or a comment all blocked.
This scanner reads the command the way a shell does and answers only the
question the guard cares about: would `uv` or `uvx` run?

Exit codes (read by block-uv.sh):
    0   no uv/uvx command found
    10  a uv/uvx command was found
    3   the command could not be parsed with confidence
    any other code (a crash exits 1, a missing interpreter 127) also means
    "could not decide"; the caller must then fall back to its own broad regex
    (fail closed). "Found" is 10, not 1, so a crash never reads as a hit.

What counts as a hit:
    * any unquoted word that is `uv` or `uvx`, or a path ending in /uv or /uvx
      (this keeps `pip install uv`, `which uv`, and `./uv sync` blocked)
    * a quoted command word (`'uv' sync`) and spellings like `u"v"`
    * anything inside `$(...)` or backticks, even inside double quotes
    * quoted strings passed to a shell or launcher (`bash -c "..."`, `ssh host
      '...'`, `eval "..."`, `tmux send-keys '...'`), scanned as shell code
    * heredoc bodies and piped text that reach a shell (`bash <<EOF`,
      `echo "..." | sh`)
    * code-shaped strings passed to an interpreter (`python3 -c 'os.system(
      "uv sync")'`, `["uv", "sync"]`)

What does not count: `uv` inside quoted text given to a data command (`echo`,
`grep`, `git commit -m`, `gh pr create --body`), heredoc bodies fed to a
non-shell command, and comments.

Known limits, accepted because this guard is a speed bump and not a security
boundary: variable indirection (`$UV sync`), `$'...'` quoting, and text built
at run time and handed to a shell through process substitution are not
resolved. Anything that confuses the parser exits 3 instead of passing.

Compatible with Python 3.10 and newer, the floor for the deployed hooks.
"""

import re
import sys

UV_NAMES = frozenset({"uv", "uvx"})
MAX_DEPTH = 6

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


def _cmd_runs_uv(cmd, carrier, interp, depth):
    words = cmd.words
    for word in words:
        if _base(word.value) in UV_NAMES and word.has_bare:
            return True  # unquoted `uv`, or a mixed spelling such as u"v"
    command_words = _command_words(cmd)
    if command_words and _base(command_words[0].value) in UV_NAMES:
        return True  # a fully quoted command word: 'uv' sync
    if carrier and any(_base(word.value) in UV_NAMES for word in words):
        return True
    for sub in cmd.subs:
        if _scan(sub, depth + 1):
            return True
    for word in words:
        for kind, part in word.parts:
            if kind == "bare":
                continue
            if carrier and _scan(part, depth + 1):
                return True
            if interp and CODE_SHAPED.search(part):
                return True
    for body, expands in cmd.heredocs:
        if carrier and _scan(body, depth + 1):
            return True
        if interp and CODE_SHAPED.search(body):
            return True
        if expands and not carrier:
            for sub in _extract_subs(body):
                if _scan(sub, depth + 1):
                    return True
    return False


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
    for cmd in cmds:
        carrier, interp = flags[cmd.group]
        if _cmd_runs_uv(cmd, carrier, interp, depth):
            return True
    return False


def runs_uv(command):
    """Return True if *command* would run uv or uvx. Raise ParseError if unsure."""
    return _scan(command, 0)


def main():
    text = sys.stdin.read()
    try:
        found = runs_uv(text)
    except Exception:  # ParseError, RecursionError, anything unexpected: fail closed
        return 3
    return 10 if found else 0


if __name__ == "__main__":
    sys.exit(main())
