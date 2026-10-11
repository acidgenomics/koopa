"""Read a shell command line the way a shell does, without running it.

A hook that greps the raw text of a command cannot tell a command from text that
merely mentions it: a commit message, a `grep` pattern, a heredoc body, or a
comment all look the same as a real call. This module tokenizes the command and
lists every simple command that would actually run, so a policy can ask about
commands instead of about strings.

`walk(command)` returns one `Invocation` per simple command. It descends into
everything the shell would execute:

    * `$(...)` and backtick substitutions, even inside double quotes
    * quoted strings handed to a shell or launcher (`bash -c "..."`,
      `ssh host '...'`, `eval "..."`, `tmux send-keys '...'`)
    * heredoc bodies and piped text that reach a shell (`bash <<EOF`,
      `echo "..." | sh`)

It does not treat as code: quoted text given to data commands (`echo`, `grep`,
`git commit -m`), comments, or heredoc bodies fed to non-shell commands. Text
given to an interpreter (`python3 -c`, `Rscript -e`, `node -e`) is returned as
`payloads` so a policy can apply its own pattern to it.

Anything the tokenizer cannot parse with confidence raises `ParseError`, so a
caller can fail closed or defer, whichever its policy says.

Known limits: variable indirection (`$CMD arg`), `$'...'` quoting, and text built
at run time and handed to a shell through process substitution are not resolved.

Needs Python 3.10 or newer. Hooks run under whichever `python3` comes first on
PATH, so the system `python3` that macOS ships (3.9) must not come first.
"""

import re
from dataclasses import dataclass

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
        "R",
        "Rscript",
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
        "ruby",
    }
)
_PYTHON = re.compile(r"^python[0-9.]*$")
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")


# Options of each wrapper that take a value in the next word. A wrapper missing
# here, or an option missing from its set, is read as a flag with no value.
VALUE_OPTS = {
    "sudo": frozenset(
        [
            "-u",
            "-g",
            "-C",
            "-h",
            "-p",
            "-r",
            "-t",
            "-U",
            "-D",
            "-R",
            "-T",
            "--user",
            "--group",
            "--close-from",
            "--host",
            "--prompt",
            "--role",
            "--type",
            "--other-user",
            "--chdir",
            "--chroot",
            "--command-timeout",
        ]
    ),
    "doas": frozenset({"-u", "-C"}),
    "env": frozenset({"-u", "-C", "-S", "-P", "--unset", "--chdir", "--split-string"}),
    "nice": frozenset({"-n", "--adjustment"}),
    "ionice": frozenset(
        ["-c", "-n", "-p", "-P", "-u", "--class", "--classdata", "--pid", "--pgid", "--uid"]
    ),
    "stdbuf": frozenset({"-i", "-o", "-e", "--input", "--output", "--error"}),
    "xargs": frozenset(
        [
            "-a",
            "-d",
            "-E",
            "-I",
            "-L",
            "-l",
            "-n",
            "-P",
            "-s",
            "--arg-file",
            "--delimiter",
            "--eof",
            "--replace",
            "--max-lines",
            "--max-args",
            "--max-procs",
            "--max-chars",
        ]
    ),
    "timeout": frozenset({"-k", "-s", "--kill-after", "--signal"}),
    "flock": frozenset({"-w", "-E", "--timeout", "--conflict-exit-code"}),
    "exec": frozenset({"-a"}),
    "caffeinate": frozenset({"-t", "-w"}),
    "time": frozenset({"-f", "-o", "--format", "--output"}),
}
# Positional words a wrapper takes before the command it runs.
POSITIONALS = {"timeout": 1, "flock": 1}


class ParseError(Exception):
    """The command could not be tokenized with confidence."""


@dataclass(frozen=True)
class Invocation:
    """One simple command that would run.

    argv: the command's words with quotes removed and leading `NAME=value`
        assignments dropped.
    pipeline: basenames of every command in the same pipeline, including the
        words after a wrapper such as `sudo` or `env`.
    sub_names: basenames of the commands run inside this command's `$(...)` and
        backtick substitutions.
    interpreter: True when the pipeline feeds an interpreter such as `python3`.
    payloads: quoted strings and heredoc bodies handed to that interpreter.
    """

    argv: list
    pipeline: frozenset
    sub_names: frozenset
    interpreter: bool
    payloads: list


class _Word:
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


class _Cmd:
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
        self.cmd = _Cmd(self.group)
        self.parts = []
        self.pending = []

    def add_bare(self, ch):
        if self.parts and self.parts[-1][0] == "bare":
            self.parts[-1] = ("bare", self.parts[-1][1] + ch)
        else:
            self.parts.append(("bare", ch))

    def end_word(self):
        if self.parts:
            self.cmd.words.append(_Word(self.parts))
            self.parts = []

    def end_cmd(self, new_group):
        self.end_word()
        if self.cmd.words or self.cmd.subs or self.cmd.touched:
            self.cmds.append(self.cmd)
        if new_group:
            self.group += 1
        self.cmd = _Cmd(self.group)

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


def base(value):
    """Return the last path component of *value* (`/usr/bin/pip` -> `pip`)."""
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
    head = base(words[0].value)
    names = {head}
    if head in WRAPPERS:
        for word in words[1:]:
            if word.all_bare:
                names.add(base(word.value))
    return names


def _is_interpreter(name):
    return name in INTERPRETERS or bool(_PYTHON.match(name))


def _walk(text, depth, out):
    if depth > MAX_DEPTH:
        raise ParseError("commands nested too deeply")
    cmds = _Parser(text).parse()
    by_group = {}
    for cmd in cmds:
        by_group.setdefault(cmd.group, []).append(cmd)
    info = {}
    for group, members in by_group.items():
        names = set()
        for member in members:
            names |= _names(member)
        info[group] = (
            frozenset(names),
            bool(names & CODE_CARRIERS),
            any(_is_interpreter(name) for name in names),
        )
    for cmd in cmds:
        names, carrier, interp = info[cmd.group]
        nested = list(cmd.subs)
        payloads = []
        for word in cmd.words:
            for kind, part in word.parts:
                if kind == "bare":
                    continue
                if carrier:
                    nested.append(part)
                if interp:
                    payloads.append(part)
        for body, expands in cmd.heredocs:
            if carrier:
                nested.append(body)
            if interp:
                payloads.append(body)
            if expands and not carrier:
                nested.extend(_extract_subs(body))
        sub_names = set()
        for sub in cmd.subs:
            for sub_cmd in _Parser(sub).parse():
                sub_names |= _names(sub_cmd)
        out.append(
            Invocation(
                argv=[word.value for word in _command_words(cmd)],
                pipeline=names,
                sub_names=frozenset(sub_names),
                interpreter=interp,
                payloads=payloads,
            )
        )
        for text_to_walk in nested:
            _walk(text_to_walk, depth + 1, out)


def walk(command):
    """Return every simple command in *command* that would run.

    Raises ParseError when the command cannot be tokenized with confidence.
    """
    out = []
    _walk(command, 0, out)
    return out


def skip_options(argv, i, wrapper):
    """Return the index after the options and assignments that follow a wrapper word."""
    value_opts = VALUE_OPTS.get(wrapper, frozenset())
    while i < len(argv):
        word = argv[i]
        if word == "--":
            return i + 1
        if "=" in word and not word.startswith("-"):
            i += 1  # `env NAME=value cmd`
        elif word.startswith("--"):
            i += 2 if word in value_opts else 1
        elif word.startswith("-") and len(word) > 1:
            letters = word[1:]
            takes_value = False
            for pos, letter in enumerate(letters):
                if "-" + letter in value_opts:
                    takes_value = pos == len(letters) - 1  # `-n5` carries its value
                    break
            i += 2 if takes_value else 1
        else:
            return i
    return i


def command_index(argv):
    """Return the index of the command word that really runs, looking past wrappers."""
    i = 0
    while i < len(argv):
        name = base(argv[i])
        if name not in WRAPPERS and name != "busybox":
            return i
        i = skip_options(argv, i + 1, name) + POSITIONALS.get(name, 0)
    return None
