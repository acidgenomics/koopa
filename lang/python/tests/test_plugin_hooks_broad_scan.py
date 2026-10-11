"""Tests for the koopa plugin's broad-scan guard (plugins/koopa/hooks/guard_broad_scan.py).

The guard blocks ``find``, ``grep -r``/``-R``, ``rg``, and ``fd``/``fdfind`` rooted at
``~``, ``$HOME``, ``/``, ``/Users``, ``/home``, or a bare home directory, and lets
deeper project paths through. Every test sends payload text only; no scan is run.

Two lists drive the file. BLOCKED must stay blocked. ALLOWED must pass.
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

hook = importlib.import_module("guard_broad_scan")

_ENTRY = _HOOKS_DIR / "guard_broad_scan.py"


def _run(stdin: str) -> tuple[int, str]:
    """Run the real hook entry; return ``(exit code, stderr)``."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    try:
        proc = subprocess.run(
            [sys.executable, "-B", "-E", "-s", str(_ENTRY)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError as error:
        return error.returncode, error.stderr
    return proc.returncode, proc.stderr


def _claude(command: str) -> str:
    """Build a Claude Code PreToolUse payload."""
    return json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})


def _copilot(*commands: str) -> str:
    """Build a Copilot CLI batched ``toolCalls[]`` payload."""
    return json.dumps({"toolCalls": [{"args": {"command": c}} for c in commands]})


BLOCKED = [
    pytest.param("find ~ -name '*.py'", id="find tilde"),
    pytest.param("find ~/ -name x", id="find tilde slash"),
    pytest.param("find $HOME -name x", id="find $HOME"),
    pytest.param("find ${HOME} -name x", id="find ${HOME}"),
    pytest.param("find / -name x", id="find root"),
    pytest.param("find /Users -name x", id="find /Users"),
    pytest.param("find /home -name x", id="find /home"),
    pytest.param("find /Users/someone -name x", id="find bare home"),
    pytest.param("find /Users/someone/ -name x", id="find bare home trailing slash"),
    pytest.param("find /home/someone -type f", id="find linux home"),
    pytest.param("find -L / -name x", id="find after -L"),
    pytest.param("find -H -P ~ -name x", id="find after -H -P"),
    pytest.param("cd x && find / -name y", id="find after &&"),
    pytest.param("grep -r foo ~", id="grep -r tilde"),
    pytest.param("grep -rn foo /", id="grep -rn root"),
    pytest.param("grep -R foo $HOME", id="grep -R $HOME"),
    pytest.param("grep -ri foo /Users/someone", id="grep -ri bare home"),
    pytest.param("rg foo ~", id="rg tilde"),
    pytest.param("rg -i foo /", id="rg root"),
    pytest.param("rg foo /home/someone", id="rg bare home"),
    pytest.param("fd pattern ~", id="fd tilde"),
    pytest.param("fdfind pattern /", id="fdfind root"),
    pytest.param("ls\nfind / -name x", id="second line of a multi-line command"),
    pytest.param("echo hi\nrg foo ~", id="rg on a later line"),
]

ALLOWED = [
    pytest.param("ls -la", id="plain command"),
    pytest.param("find . -name '*.py'", id="find cwd"),
    pytest.param("find src -name x", id="find subdir"),
    pytest.param("find /Users/someone/project -name x", id="find under home"),
    pytest.param("find /home/someone/project -name x", id="find under linux home"),
    pytest.param("find /var/log -name x", id="find other system path"),
    pytest.param("find ~/project -name x", id="find under tilde"),
    pytest.param("find $HOME/project -name x", id="find under $HOME"),
    pytest.param("find -name x", id="find with no root"),
    pytest.param("grep -r foo src", id="grep -r subdir"),
    pytest.param("grep foo ~", id="grep without -r"),
    pytest.param("grep -n foo file.txt", id="grep file"),
    pytest.param("rg foo src", id="rg subdir"),
    pytest.param("rg foo ~/project", id="rg under tilde"),
    pytest.param("fd pattern src", id="fd subdir"),
    pytest.param("echo 'find /' > notes.txt", id="quoted find is not a scan root"),
    pytest.param("git log --oneline", id="unrelated command"),
]


@pytest.mark.parametrize("command", BLOCKED)
def test_broad_scans_are_found(command: str) -> None:
    """Every broad scan shape is detected."""
    assert hook.is_broad_scan(command)


@pytest.mark.parametrize("command", ALLOWED)
def test_scoped_scans_pass(command: str) -> None:
    """Scoped scans and unrelated commands are not detected."""
    assert not hook.is_broad_scan(command)


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("~", True),
        ("~/", True),
        ("$HOME", True),
        ("${HOME}", True),
        ("$HOME/", True),
        ("/", True),
        ("/Users", True),
        ("/Users/", True),
        ("/home", True),
        ("/Users/someone", True),
        ("/Users/someone/", True),
        ("/home/someone", True),
        ("/Users/someone/project", False),
        ("/home/someone/project", False),
        ("~/project", False),
        ("$HOME/project", False),
        ("/var", False),
        (".", False),
        ("src", False),
    ],
)
def test_is_broad_root(raw: str, expected: bool) -> None:
    """The root classifier matches the documented set exactly."""
    assert hook.is_broad_root(raw) is expected


# ---------------------------------------------------------------------------
# the real hook entry
# ---------------------------------------------------------------------------


def test_entry_blocks_claude_payload() -> None:
    """A Claude payload that scans from the root exits 2 with the reason on stderr."""
    code, stderr = _run(_claude("find / -name secrets"))
    assert code == 2
    assert json.loads(stderr)["decision"] == "block"
    assert "Broad filesystem scan blocked" in json.loads(stderr)["reason"]


def test_entry_blocks_copilot_batch() -> None:
    """A broad scan hidden in a later toolCalls[] entry still blocks."""
    code, _stderr = _run(_copilot("pwd", "rg foo ~"))
    assert code == 2


def test_entry_allows_scoped_scan_and_batch() -> None:
    """Scoped scans pass in both payload shapes."""
    assert _run(_claude("find src -name x"))[0] == 0
    assert _run(_copilot("pwd", "rg foo src"))[0] == 0


def test_entry_allows_a_batch_with_no_command_field() -> None:
    """A batch whose entries carry no ``command`` key defers."""
    assert _run(json.dumps({"toolCalls": [{"args": {"path": "a.py"}}]}))[0] == 0


@pytest.mark.parametrize("stdin", ["", "   \n", "{not json", "[1, 2]", "{}", '{"tool_input": "x"}'])
def test_entry_fails_open_on_empty_or_malformed_stdin(stdin: str) -> None:
    """Empty, malformed, or unrecognized input exits 0."""
    assert _run(stdin)[0] == 0
