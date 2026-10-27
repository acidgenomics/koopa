"""Tests for the koopa plugin's uv guard (plugins/koopa/hooks).

Covers ``uv_command_scan.py`` and the ``block_uv.py`` entry. The guard once ran one
regex over the raw command text, so it flagged a Bash call that only *mentioned*
``uv``: a Python heredoc whose body was a report containing the words "uv lock". The
scanner reads the command the way a shell does, so text inside quotes, comments, and
non-shell heredocs passes, while every way of actually running ``uv`` or ``uvx`` is
still found.

A found call is then classified. A read-only probe (``uv --version``, ``uv pip
list``) passes with no decision. Anything that may change dependencies, or cannot be
classified, makes the entry print a ``permissionDecision: ask``: never a block, and
never an allow.

The lists drive most of the file. DETECTED must stay detected (a regression reopens
the guard). NEEDS_APPROVAL must ask. PROBES must pass without a prompt. ALLOWED must
not be detected at all (a regression brings the false positives back). Every test
sends payload text only; nothing here runs uv.
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
uv_verdict = _uv.uv_verdict
classify_uv = _uv.classify_uv
ParseError = _uv.ParseError
NONE, PROBE, CHANGE = _uv.NONE, _uv.PROBE, _uv.CHANGE

_SCANNER = _HOOKS_DIR / "uv_command_scan.py"
_ENTRY = _HOOKS_DIR / "block_uv.py"


def _run(stdin: str, harness: str | None = None) -> subprocess.CompletedProcess:
    """Run the real hook entry with a payload on stdin; a nonzero exit is returned, not raised."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    env.pop("AGENT_HOOK_HARNESS", None)
    if harness is not None:
        env["AGENT_HOOK_HARNESS"] = harness
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


def _decision(result: subprocess.CompletedProcess) -> str | None:
    """The permission decision printed by the hook (Claude shape), or None for no output."""
    if not result.stdout.strip():
        return None
    return json.loads(result.stdout)["hookSpecificOutput"]["permissionDecision"]


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

NEEDS_APPROVAL = [
    pytest.param("uv sync", id="bare uv"),
    pytest.param("uvx ruff check .", id="bare uvx"),
    pytest.param("uv pip install requests", id="uv pip"),
    pytest.param("uv run pytest -q", id="uv run"),
    pytest.param("cd repo && uv sync", id="after &&"),
    pytest.param("false; uv sync", id="after ;"),
    pytest.param("false || uv sync", id="after ||"),
    pytest.param("echo hi | uv sync", id="after pipe"),
    pytest.param("(uv sync)", id="subshell"),
    pytest.param("{ uv sync; }", id="brace group"),
    pytest.param("if uv sync; then echo ok; fi", id="inside if"),
    pytest.param("nohup uv sync &", id="nohup"),
    pytest.param("time uv sync", id="time"),
    pytest.param("FOO=1 uv run x", id="env assignment prefix"),
    pytest.param("env X=1 uv sync", id="env wrapper"),
    pytest.param("sudo -u root uv sync", id="sudo with option value"),
    pytest.param("timeout 60 uv sync", id="timeout wrapper"),
    pytest.param("/usr/local/bin/uv sync", id="absolute path"),
    pytest.param("~/.local/bin/uvx foo", id="home path"),
    pytest.param("./uv sync", id="relative path"),
    pytest.param("python3 -m uv sync", id="python -m uv"),
    pytest.param("x=$(uv sync)", id="command substitution"),
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
    pytest.param("ssh host uv sync", id="ssh unquoted remote command"),
    pytest.param("ssh host 'uv pip list && uv sync'", id="ssh probe then change"),
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
        'python3 -c \'import subprocess; subprocess.run(["uv", "--version"])\'',
        id="interpreter code is never classified as a probe",
    ),
    pytest.param(
        "node -e \"require('child_process').execSync('uv sync')\"",
        id="node execSync",
    ),
    pytest.param("echo ok\nuv sync", id="second line"),
    pytest.param("ls\nuv sync", id="batched calls joined by newline"),
    pytest.param("uv --version\nuv sync", id="probe then change on the next line"),
    pytest.param("uv pip list; uv add requests", id="probe then change after ;"),
    pytest.param("echo sync | xargs uv", id="xargs supplies the subcommand"),
    pytest.param("uv --unknown-flag pip list", id="unknown global option"),
    pytest.param("uv --directory list sync", id="valued global option is skipped"),
    pytest.param("uv add requests", id="uv add"),
    pytest.param("uv remove requests", id="uv remove"),
    pytest.param("uv lock", id="uv lock rewrites the lockfile"),
    pytest.param("uv lock --upgrade", id="uv lock --upgrade"),
    pytest.param("uv tree", id="uv tree may lock"),
    pytest.param("uv export -o requirements.txt", id="uv export"),
    pytest.param("uv venv", id="uv venv"),
    pytest.param("uv pip compile pyproject.toml", id="uv pip compile"),
    pytest.param("uv pip sync requirements.txt", id="uv pip sync"),
    pytest.param("uv pip uninstall requests", id="uv pip uninstall"),
    pytest.param("uv python install 3.14", id="uv python install"),
    pytest.param("uv tool install ruff", id="uv tool install"),
    pytest.param("uv tool run ruff --help", id="uv tool run --help runs the tool"),
    pytest.param("uv run pytest --help", id="uv run --help runs the program"),
    pytest.param("uv self update", id="uv self update"),
    pytest.param("uv cache clean", id="uv cache clean"),
    pytest.param("uv version --bump minor", id="uv version --bump"),
    pytest.param("uv version 1.2.3", id="uv version set"),
    pytest.param("uvx ruff --version", id="uvx downloads before --version"),
]

PROBES = [
    pytest.param("uv", id="bare uv prints help"),
    pytest.param("uvx", id="bare uvx prints help"),
    pytest.param("uv --version", id="uv --version"),
    pytest.param("uv -V", id="uv -V"),
    pytest.param("uvx --version", id="uvx --version"),
    pytest.param("uv --help", id="uv --help"),
    pytest.param("uv help sync", id="uv help"),
    pytest.param("uv sync --help", id="subcommand --help"),
    pytest.param("uv pip install -h", id="subcommand -h"),
    pytest.param("uv -q --directory sub pip list", id="global options before pip list"),
    pytest.param("uv --project=sub tree --frozen", id="--project= then tree --frozen"),
    pytest.param("uv pip list", id="uv pip list"),
    pytest.param("uv pip show requests", id="uv pip show"),
    pytest.param("uv pip freeze", id="uv pip freeze"),
    pytest.param("uv pip tree", id="uv pip tree"),
    pytest.param("uv pip check", id="uv pip check"),
    pytest.param("uv tree --locked", id="uv tree --locked"),
    pytest.param("uv lock --check", id="uv lock --check"),
    pytest.param("uv lock --dry-run", id="uv lock --dry-run"),
    pytest.param("uv python list", id="uv python list"),
    pytest.param("uv python find 3.14", id="uv python find"),
    pytest.param("uv tool list", id="uv tool list"),
    pytest.param("uv tool dir", id="uv tool dir"),
    pytest.param("uv cache dir", id="uv cache dir"),
    pytest.param("uv self version", id="uv self version"),
    pytest.param("uv version", id="uv version"),
    pytest.param("uv version --short", id="uv version --short"),
    pytest.param("which uv", id="which uv"),
    pytest.param("command -v uv", id="command -v uv"),
    pytest.param("pip install uv", id="installing uv is the install guard's call"),
    pytest.param("echo hi | uv", id="bare uv after a pipe"),
    pytest.param("x=$(uv --version)", id="probe in a substitution"),
    pytest.param("sudo -u root uv pip list", id="probe behind sudo"),
    pytest.param("env X=1 uv --version", id="probe behind env"),
    pytest.param("ssh host uv --version", id="ssh unquoted probe"),
    pytest.param("ssh host 'uv pip list'", id="ssh quoted probe"),
    pytest.param("bash -lc 'uv tree --frozen'", id="bash -lc probe"),
    pytest.param("ssh host <<'EOF'\nuv --version\nuv pip list\nEOF", id="heredoc probes into ssh"),
    pytest.param("uv --version\nuv pip list", id="batched probes"),
    pytest.param("uv pip list | grep requests", id="probe piped to grep"),
]

DETECTED = NEEDS_APPROVAL + PROBES

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


@pytest.mark.parametrize("command", DETECTED)
def test_commands_that_run_uv_are_found(command: str) -> None:
    """Every way of actually running uv or uvx must still be found."""
    assert runs_uv(command) is True


@pytest.mark.parametrize("command", NEEDS_APPROVAL)
def test_dependency_changing_uv_needs_approval(command: str) -> None:
    """A uv call that may change dependencies, or cannot be classified, asks."""
    assert uv_verdict(command) == CHANGE
    assert hook.needs_approval(command) is True


@pytest.mark.parametrize("command", PROBES)
def test_read_only_probes_pass(command: str) -> None:
    """Read-only uv probes are found but need no approval."""
    assert uv_verdict(command) == PROBE
    assert hook.needs_approval(command) is False


@pytest.mark.parametrize("command", ALLOWED)
def test_text_that_only_mentions_uv_passes(command: str) -> None:
    """Quoted text, comments, and non-shell heredocs are not uv calls."""
    assert runs_uv(command) is False
    assert uv_verdict(command) == NONE


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
    """When the parser is unsure it must say so, so the guard can fall back and ask."""
    with pytest.raises(ParseError):
        runs_uv(command)


def test_empty_command_is_clean() -> None:
    """An empty string (a tool call with no command) is not a uv call."""
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
    """`<(...)` runs its contents, so uv inside it must be found and classified."""
    assert uv_verdict("diff <(uv pip freeze) req.txt") == PROBE
    assert uv_verdict("diff <(uv pip compile x.in) req.txt") == CHANGE


@pytest.mark.parametrize(
    ("name", "args", "expected"),
    [
        pytest.param("uv", [], PROBE, id="no arguments"),
        pytest.param("uv", ["-qq", "pip", "list"], PROBE, id="repeated short switch"),
        pytest.param("uv", ["--color", "never", "pip", "freeze"], PROBE, id="valued option"),
        pytest.param("uv", ["--color=never", "sync"], CHANGE, id="valued option with ="),
        pytest.param("uv", ["pip"], CHANGE, id="pip with no verb"),
        pytest.param("uv", ["add", "x", "--", "--help"], CHANGE, id="--help after --"),
        pytest.param("uv", ["version", "--output-format", "json"], PROBE, id="version json"),
        pytest.param("uvx", ["-h"], PROBE, id="uvx -h"),
        pytest.param("uvx", ["--from", "x", "y"], CHANGE, id="uvx with options"),
    ],
)
def test_classify_uv(name: str, args: list[str], expected: int) -> None:
    """The probe allowlist decides from the argument vector alone."""
    assert classify_uv(name, args) == expected


@pytest.mark.parametrize(
    ("stdin", "expected"),
    [
        pytest.param("ls", 0, id="clean"),
        pytest.param("uv sync", 10, id="dependency change"),
        pytest.param("uv --version", 11, id="read-only probe"),
        pytest.param('echo "unterminated', 3, id="could not parse"),
    ],
)
def test_scanner_exit_codes(stdin: str, expected: int) -> None:
    """Scanner exit codes: 0 clean, 10 change, 11 probe only, 3 unsure; a crash exits 1."""
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
    """Quoted text and non-shell heredocs are not commands, so they pass silently."""
    result = _run(_claude(command))
    assert result.returncode == 0
    assert _decision(result) is None


@pytest.mark.parametrize(
    "command",
    [
        "uv --version",
        "uv pip list",
        "ssh host 'uv tree --frozen'",
        "bash -lc 'uv lock --check'",
        "uv --version\nuv pip freeze",
    ],
)
def test_entry_lets_read_only_probes_through(command: str) -> None:
    """Probes print no decision, so the harness's normal permission flow applies."""
    result = _run(_claude(command))
    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


@pytest.mark.parametrize(
    "command",
    [
        "uv sync",
        'bash -lc "uv pip install x"',
        "ssh host 'uvx x'",
        "ssh host uv add requests",
        "echo 'uv sync' | bash",
        "cat <<EOF\n$(uv sync)\nEOF",
        "FOO=1 /usr/local/bin/uv run x",
        "sudo -u root uv pip install x",
    ],
)
def test_entry_asks_before_dependency_changes(command: str) -> None:
    """Direct, wrapped, remote, piped, and substituted changes ask; never block or allow."""
    result = _run(_claude(command))
    assert result.returncode == 0
    assert result.stderr == ""
    output = json.loads(result.stdout)["hookSpecificOutput"]
    assert output["hookEventName"] == "PreToolUse"
    assert output["permissionDecision"] == "ask"
    assert "uv" in output["permissionDecisionReason"]


def test_entry_uses_the_copilot_shape_when_the_harness_says_so() -> None:
    """The Copilot registration sets AGENT_HOOK_HARNESS=copilot for a bare decision."""
    output = json.loads(_run(_claude("uv sync"), harness="copilot").stdout)
    assert output["permissionDecision"] == "ask"
    assert "hookSpecificOutput" not in output


def test_entry_asks_for_uv_in_a_copilot_batch() -> None:
    """``uv sync`` buried in a later toolCalls[] entry still asks."""
    result = _run(_copilot("pwd", "uv pip list", "uv sync"), harness="copilot")
    assert result.returncode == 0
    assert json.loads(result.stdout)["permissionDecision"] == "ask"


def test_entry_lets_a_copilot_batch_of_probes_through() -> None:
    """A batch holding only probes prints no decision."""
    result = _run(_copilot("pwd", "uv --version", "uv pip list"), harness="copilot")
    assert result.returncode == 0
    assert result.stdout == ""


def test_entry_allows_a_batch_with_no_command_field() -> None:
    """A batch whose entries carry no ``command`` key defers."""
    result = _run(json.dumps({"toolCalls": [{"args": {"path": "a.py"}}]}))
    assert result.returncode == 0
    assert result.stdout == ""


def test_entry_asks_when_the_command_cannot_be_parsed() -> None:
    """An unterminated quote defeats the scanner, so the broad pattern decides, and asks."""
    assert _decision(_run(_claude('echo "oops uv sync'))) == "ask"
    assert _decision(_run(_claude('echo "oops uv --version'))) == "ask"
    assert _decision(_run(_claude('echo "oops ls'))) is None


def test_needs_approval_falls_back_when_the_scanner_crashes(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Any scanner error, not only ParseError, hands the decision to the broad pattern."""

    def boom(_command: str) -> int:
        raise RuntimeError("scanner crashed")

    monkeypatch.setattr(hook, "uv_verdict", boom)
    assert hook.needs_approval("ls -la") is False
    assert hook.needs_approval("uv sync") is True
    # An extra prompt is the price of not knowing.
    assert hook.needs_approval('echo "run uv lock"') is True


@pytest.mark.parametrize("stdin", ["", "   \n", "{not json", "[1, 2]", "{}", '{"tool_input": "x"}'])
def test_entry_fails_open_on_empty_or_malformed_stdin(stdin: str) -> None:
    """Empty, malformed, or unrecognized input exits 0 with no decision."""
    result = _run(stdin)
    assert result.returncode == 0
    assert result.stdout == ""
