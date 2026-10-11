"""Tests for the koopa plugin's uv guard (plugins/koopa/hooks).

Covers ``uv_command_scan.py`` and the ``block_uv.py`` entry. The guard once ran one
regex over the raw command text, so it blocked a Bash call that only *mentioned*
``uv``: a Python heredoc whose body was a report containing the words "uv lock". The
scanner reads the command the way a shell does, so text inside quotes, comments, and
non-shell heredocs no longer blocks, while every way of actually running ``uv`` or
``uvx`` still does.

Two lists drive most of the file. BLOCKED must stay blocked (a regression here
reopens the guard). ALLOWED must pass (a regression here brings the false positives
back). Every test sends payload text only; nothing here runs uv.
"""

import importlib
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True

_HOOKS_DIR = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
sys.path.insert(0, str(_HOOKS_DIR))

_uv = importlib.import_module("uv_command_scan")
hook = importlib.import_module("block_uv")

runs_uv = _uv.runs_uv
ParseError = _uv.ParseError

_SCANNER = _HOOKS_DIR / "uv_command_scan.py"
_ENTRY = _HOOKS_DIR / "block_uv.py"


def _run(stdin: str) -> subprocess.CompletedProcess:
    """Run the real hook entry with a payload on stdin; a nonzero exit is returned, not raised."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    try:
        return subprocess.run(
            [sys.executable, "-B", "-E", "-s", str(_ENTRY)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def _claude(command: str) -> str:
    """Build a Claude Code PreToolUse payload."""
    return json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})


def _copilot(*commands: str) -> str:
    """Build a Copilot CLI batched ``toolCalls[]`` payload."""
    return json.dumps({"toolCalls": [{"args": {"command": c}} for c in commands]})


# A report body written through a Python heredoc: the exact shape that was
# wrongly blocked. It names uv three ways (backticks, a table cell, a file name).
_REPORT_HEREDOC = (
    "python3 -I - <<'EOF'\n"
    "body = '''\n"
    "| Lock files | Refreshed by the user (`uv lock`, then the `uv export`). |\n"
    "`uv.lock` is gitignored. Agents cannot run uv here.\n"
    "'''\n"
    "print(len(body))\n"
    "EOF"
)

BLOCKED = [
    pytest.param("uv sync", id="bare uv"),
    pytest.param("uvx ruff check .", id="bare uvx"),
    pytest.param("uv pip install requests", id="uv pip"),
    pytest.param("uv run pytest -q", id="uv run"),
    pytest.param("cd repo && uv sync", id="after &&"),
    pytest.param("false; uv sync", id="after ;"),
    pytest.param("false || uv sync", id="after ||"),
    pytest.param("echo hi | uv", id="after pipe"),
    pytest.param("(uv sync)", id="subshell"),
    pytest.param("{ uv sync; }", id="brace group"),
    pytest.param("if uv sync; then echo ok; fi", id="inside if"),
    pytest.param("nohup uv sync &", id="nohup"),
    pytest.param("time uv sync", id="time"),
    pytest.param("FOO=1 uv run x", id="env assignment prefix"),
    pytest.param("env X=1 uv sync", id="env wrapper"),
    pytest.param("sudo -u root uv sync", id="sudo with option value"),
    pytest.param("/usr/local/bin/uv sync", id="absolute path"),
    pytest.param("~/.local/bin/uvx foo", id="home path"),
    pytest.param("./uv sync", id="relative path"),
    pytest.param("pip install uv", id="installing uv"),
    pytest.param("which uv", id="probing for uv"),
    pytest.param("python3 -m uv sync", id="python -m uv"),
    pytest.param("x=$(uv --version)", id="command substitution"),
    pytest.param("echo `uv sync`", id="backtick substitution"),
    pytest.param('echo "$(uv sync)"', id="substitution inside double quotes"),
    pytest.param('echo "a $(echo $(uv sync)) b"', id="nested substitution"),
    pytest.param("'uv' sync", id="single-quoted command word"),
    pytest.param('"uv" sync', id="double-quoted command word"),
    pytest.param('u"v" sync', id="split spelling"),
    pytest.param('bash -lc "uv pip install x"', id="bash -lc"),
    pytest.param("sh -c 'uvx x'", id="sh -c"),
    pytest.param("zsh -c 'cd x && uv sync'", id="zsh -c chain"),
    pytest.param("ssh host 'uvx x'", id="ssh remote command"),
    pytest.param('eval "uv sync"', id="eval"),
    pytest.param("tmux send-keys 'uv sync' Enter", id="tmux send-keys"),
    pytest.param("docker exec c sh -c 'uv sync'", id="docker exec sh -c"),
    pytest.param("env FOO=1 bash -c 'uv sync'", id="env then bash -c"),
    pytest.param("echo 'uv sync' | bash", id="piped into bash"),
    pytest.param("printf 'uv sync\\n' | sh", id="printf piped into sh"),
    pytest.param("cat <<EOF | sh\nuv sync\nEOF", id="heredoc piped into sh"),
    pytest.param("bash <<'EOF'\nuv sync\nEOF", id="heredoc into bash"),
    pytest.param("ssh host <<'EOF'\nuv sync\nEOF", id="heredoc into ssh"),
    pytest.param("cat <<EOF\n$(uv sync)\nEOF", id="substitution in unquoted heredoc"),
    pytest.param("cat <<EOF\n`uv sync`\nEOF", id="backtick in unquoted heredoc"),
    pytest.param(
        "python3 -c 'import os; os.system(\"uv sync\")'",
        id="python -c os.system",
    ),
    pytest.param(
        'python3 - <<\'EOF\'\nimport subprocess\nsubprocess.run(["uv", "sync"])\nEOF',
        id="python heredoc argv list",
    ),
    pytest.param(
        "node -e \"require('child_process').execSync('uv sync')\"",
        id="node execSync",
    ),
    pytest.param("echo ok\nuv sync", id="second line"),
    pytest.param("ls\nuv sync", id="batched calls joined by newline"),
]

ALLOWED = [
    pytest.param("ls -la", id="plain command"),
    pytest.param("pytest -q", id="pytest"),
    pytest.param("cat uv.lock", id="uv.lock file name"),
    pytest.param("ls uv.lock requirements.txt", id="uv.lock in a list"),
    pytest.param("echo block-uv.sh uvicorn uvloop", id="names that contain uv"),
    pytest.param("grep -rn 'uv sync' docs", id="grep pattern"),
    pytest.param('grep -c "uv lock" CHANGELOG.md', id="grep double-quoted pattern"),
    pytest.param("git log --grep='uv' --oneline", id="git log grep"),
    pytest.param('git commit -m "bump uv version"', id="commit message"),
    pytest.param("gh pr create --body 'Refresh with uv sync'", id="PR body"),
    pytest.param('echo "run uv lock then uv export"', id="echo"),
    pytest.param("printf '%s\\n' 'uv sync is blocked'", id="printf"),
    pytest.param('obsidian append path=a.md content="- uv lock needed"', id="obsidian content"),
    pytest.param("jq '.uv' f.json", id="jq filter"),
    pytest.param("# uv sync is blocked here", id="comment line"),
    pytest.param("echo hi # uv sync", id="trailing comment"),
    pytest.param("cat <<'EOF' > notes.md\nuv sync\nuv lock\nEOF", id="heredoc into cat"),
    pytest.param("cat <<EOF\nplain text about uv sync\nEOF", id="unquoted heredoc into cat"),
    pytest.param(
        "git commit -F - <<'EOF'\nbump uv\n\nrun uv lock\nEOF", id="commit message heredoc"
    ),
    pytest.param(
        "python3 - <<'EOF'\nprint('the user ran `uv lock`')\nEOF",
        id="python heredoc prose in backticks",
    ),
    pytest.param(
        "python3 - <<'EOF'\nprint('uv')\nEOF",
        id="python heredoc quoted bare word",
    ),
    pytest.param(_REPORT_HEREDOC, id="the report heredoc that was wrongly blocked"),
    pytest.param("echo 'a $(uv sync) b'", id="substitution inside single quotes is text"),
    pytest.param('echo "\\$(uv sync)"', id="escaped substitution in double quotes is text"),
]


@pytest.mark.parametrize("command", BLOCKED)
def test_commands_that_run_uv_are_found(command: str) -> None:
    """Every way of actually running uv or uvx must still be caught."""
    assert runs_uv(command) is True


@pytest.mark.parametrize("command", ALLOWED)
def test_text_that_only_mentions_uv_passes(command: str) -> None:
    """Quoted text, comments, and non-shell heredocs must not block."""
    assert runs_uv(command) is False


@pytest.mark.parametrize(
    "command",
    [
        pytest.param('echo "oops uv sync', id="unterminated double quote"),
        pytest.param("echo 'oops uv sync", id="unterminated single quote"),
        pytest.param("echo $(uv sync", id="unterminated substitution"),
        pytest.param("echo `uv sync", id="unterminated backtick"),
        pytest.param("cat <<EOF\nuv sync", id="unterminated heredoc"),
        pytest.param("cat <<EOF", id="heredoc with no body"),
        pytest.param("cat <<", id="heredoc with no delimiter"),
        pytest.param("echo " + "$(" * 9 + "x" + ")" * 9, id="nested too deeply"),
    ],
)
def test_unparseable_input_raises_instead_of_passing(command: str) -> None:
    """When the parser is unsure it must say so, so the guard can fail closed."""
    with pytest.raises(ParseError):
        runs_uv(command)


def test_empty_command_is_clean() -> None:
    """An empty string (a tool call with no command) must not block."""
    assert runs_uv("") is False


def test_heredoc_with_tab_stripped_delimiter() -> None:
    """`<<-` allows a tab-indented terminator."""
    assert runs_uv("cat <<-EOF\n\tuv sync\n\tEOF") is False
    assert runs_uv("bash <<-EOF\n\tuv sync\n\tEOF") is True


def test_two_heredocs_on_one_line() -> None:
    """Each heredoc body is read in order and judged by its own consumer."""
    command = "cat <<A; bash <<B\ntext about uv\nA\nuv sync\nB"
    assert runs_uv(command) is True


def test_process_substitution_contents_are_checked() -> None:
    """`<(...)` runs its contents, so uv inside it must be found."""
    assert runs_uv("diff <(uv pip freeze) req.txt") is True


@pytest.mark.parametrize(
    ("stdin", "expected"),
    [
        pytest.param("ls", 0, id="clean"),
        pytest.param("uv sync", 10, id="found"),
        pytest.param('echo "unterminated', 3, id="could not parse"),
    ],
)
def test_exit_codes_match_what_the_guard_reads(stdin: str, expected: int) -> None:
    """The scanner exit codes (0 clean, 10 found, else unsure) are a contract; a crash exits 1."""
    try:
        code = subprocess.run(
            [sys.executable, "-B", "-I", str(_SCANNER)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
        ).returncode
    except subprocess.CalledProcessError as error:
        code = error.returncode
    assert code == expected


# ---------------------------------------------------------------------------
# the real hook entry
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "command",
    [
        pytest.param(
            "python3 -I - <<'EOF'\nprint('the user ran `uv lock`')\nEOF",
            id="python heredoc report text",
        ),
        pytest.param('git commit -m "bump uv version"', id="commit message"),
        pytest.param("grep -rn 'uv sync' docs", id="grep pattern"),
        pytest.param('echo "run uv lock"', id="echo"),
    ],
)
def test_entry_allows_text_that_only_mentions_uv(command: str) -> None:
    """Quoted text and non-shell heredocs are not commands, so they pass."""
    assert _run(_claude(command)).returncode == 0


@pytest.mark.parametrize(
    "command",
    [
        "uv sync",
        'bash -lc "uv pip install x"',
        "ssh host 'uvx x'",
        "echo 'uv sync' | bash",
        "cat <<EOF\n$(uv sync)\nEOF",
        "FOO=1 /usr/local/bin/uv run x",
    ],
)
def test_entry_blocks_real_uv_commands(command: str) -> None:
    """Direct, wrapped, remote, piped, and substituted uv calls all block."""
    result = _run(_claude(command))
    assert result.returncode == 2
    assert "uv" in result.stderr.lower()
    assert json.loads(result.stderr)["decision"] == "block"


def test_entry_blocks_uv_in_a_copilot_batch() -> None:
    """``uv sync`` buried in a toolCalls[] batch still blocks."""
    assert _run(_copilot("pwd", "uv sync")).returncode == 2


def test_entry_allows_a_batch_with_no_command_field() -> None:
    """A batch whose entries carry no ``command`` key defers."""
    assert _run(json.dumps({"toolCalls": [{"args": {"path": "a.py"}}]})).returncode == 0


def test_entry_fails_closed_when_the_command_cannot_be_parsed() -> None:
    """An unterminated quote defeats the scanner, so the broad pattern decides."""
    assert _run(_claude('echo "oops uv sync')).returncode == 2
    assert _run(_claude('echo "oops ls')).returncode == 0


def test_uses_uv_falls_back_when_the_scanner_crashes(monkeypatch: pytest.MonkeyPatch) -> None:
    """Any scanner error, not only ParseError, hands the decision to the broad pattern."""

    def boom(_command: str) -> bool:
        raise RuntimeError("scanner crashed")

    monkeypatch.setattr(hook, "runs_uv", boom)
    assert hook.uses_uv("ls -la") is False
    assert hook.uses_uv("uv sync") is True
    # Over-blocking is the price of failing closed.
    assert hook.uses_uv('echo "run uv lock"') is True


@pytest.mark.parametrize("stdin", ["", "   \n", "{not json", "[1, 2]", "{}", '{"tool_input": "x"}'])
def test_entry_fails_open_on_empty_or_malformed_stdin(stdin: str) -> None:
    """Empty, malformed, or unrecognized input exits 0."""
    assert _run(stdin).returncode == 0
