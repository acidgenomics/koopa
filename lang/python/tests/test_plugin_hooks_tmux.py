"""Tests for the koopa plugin's tmux kill-server hook (plugins/koopa/hooks).

The hook is stand-alone Python that ships inside the plugin, so it is loaded here
by path rather than imported from the koopa package. Subprocess tests run the real
hook entry with a Claude ``tool_input`` payload and a Copilot ``toolCalls[]`` batch.
"""

import ast
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

hook = importlib.import_module("block_tmux_kill_server")
_scan = importlib.import_module("shell_command_scan")

_ENTRY = _HOOKS_DIR / "block_tmux_kill_server.py"


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


# ---------------------------------------------------------------------------
# the scanner
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "command",
    [
        "tmux kill-server",
        "tmux -L jobs kill-server",
        "ls && tmux kill-server",
        "ssh host 'tmux -L jobs kill-server'",
        'bash -lc "tmux kill-server"',
        "echo $(tmux kill-server)",
        "sudo tmux kill-server",
    ],
)
def test_scanner_blocks(command: str) -> None:
    """A command that runs tmux kill-server is detected."""
    assert hook.runs_tmux_kill_server(command)


@pytest.mark.parametrize(
    "command",
    [
        "tmux kill-session -t job",
        "tmux ls",
        "tmux -L jobs new-session -d -s job",
        "echo 'tmux kill-server'",
        "grep -n kill-server notes.md",
        "bash block-tmux-kill-server.sh",
        'git commit -m "document tmux kill-server"',
    ],
)
def test_scanner_allows(command: str) -> None:
    """A command that only mentions kill-server, or runs another subcommand, passes."""
    assert not hook.runs_tmux_kill_server(command)


def test_unparseable_command_raises() -> None:
    """The shell parser raises rather than guessing on an unterminated quote."""
    with pytest.raises(_scan.ParseError):
        list(_scan.walk('echo "unterminated tmux kill-server'))


def test_should_block_falls_back_to_text_pattern() -> None:
    """When the parser cannot decide, the original text pattern decides."""
    assert hook.should_block('echo "unterminated; tmux kill-server')
    assert not hook.should_block('echo "unterminated; tmux kill-session -t x')


# ---------------------------------------------------------------------------
# the real hook entry
# ---------------------------------------------------------------------------


def test_entry_blocks_claude_payload() -> None:
    """A Claude payload that runs kill-server exits 2 with the reason on stderr."""
    code, stderr = _run(_claude("tmux kill-server"))
    assert code == 2
    assert "kill-session -t" in stderr
    assert json.loads(stderr)["decision"] == "block"


def test_entry_blocks_copilot_batch() -> None:
    """kill-server hidden in a later toolCalls[] entry still blocks."""
    code, _stderr = _run(_copilot("pwd", "tmux -L jobs kill-server"))
    assert code == 2


def test_entry_blocks_via_text_fallback() -> None:
    """An unparseable command that contains kill-server is blocked by the fallback."""
    code, _stderr = _run(_claude('echo "unterminated; tmux kill-server'))
    assert code == 2


def test_entry_allows_mention_in_text() -> None:
    """A command that only mentions kill-server passes."""
    assert _run(_claude("echo 'tmux kill-server'"))[0] == 0
    assert _run(_copilot("grep -n kill-server notes.md"))[0] == 0


def test_entry_allows_kill_session() -> None:
    """Scoped teardown with kill-session passes."""
    assert _run(_claude("tmux kill-session -t x"))[0] == 0


@pytest.mark.parametrize("stdin", ["", "   \n", "{not json", "[1, 2]", "{}", '{"tool_input": "x"}'])
def test_entry_fails_open_on_empty_or_malformed_stdin(stdin: str) -> None:
    """Empty, malformed, or unrecognized input exits 0."""
    assert _run(stdin)[0] == 0


# ---------------------------------------------------------------------------
# portability
# ---------------------------------------------------------------------------


def test_hook_files_parse_as_python_310() -> None:
    """Every hook module parses as Python 3.10: python3 may be an old system interpreter."""
    sources = sorted(_HOOKS_DIR.glob("*.py"))
    assert {p.name for p in sources} >= {
        "audit_secrets_before_push.py",
        "block_destructive_git.py",
        "block_tmux_kill_server.py",
        "block_uv.py",
        "guard_broad_scan.py",
        "guard_env_files.py",
        "guard_git_scan.py",
        "guard_hook_writes.py",
        "guard_installs.py",
        "guard_installs_scan.py",
        "guard_keywords.py",
        "guard_report_path.py",
        "guard_rm.py",
        "guard_secret_content.py",
        "guard_sensitive_paths.py",
        "guard_settings_keywords.py",
        "guard_tmp.py",
        "guard_workspace_root.py",
        "hook_adapter.py",
        "obsidian_vault.py",
        "shell_command_scan.py",
        "uv_command_scan.py",
    }
    for path in sources:
        ast.parse(path.read_text(encoding="utf-8"), filename=str(path), feature_version=(3, 10))


def test_hooks_json_files_reference_the_entry() -> None:
    """Both hook registries wire a Bash PreToolUse command to the single entry point."""
    plugin = _HOOKS_DIR.parent
    claude = json.loads((plugin / "hooks" / "hooks.json").read_text())
    copilot = json.loads((plugin / "com.github.copilot" / "hooks" / "hooks.json").read_text())
    claude_entry = claude["hooks"]["PreToolUse"][0]
    copilot_entry = copilot["hooks"]["PreToolUse"][0]
    assert claude_entry["matcher"] == copilot_entry["matcher"] == "Bash"
    claude_command = claude_entry["hooks"][0]["command"]
    copilot_command = copilot_entry["hooks"][0]["command"]
    assert "${CLAUDE_PLUGIN_ROOT}/hooks/block_tmux_kill_server.py" in claude_command
    assert "${PLUGIN_ROOT}/hooks/block_tmux_kill_server.py" in copilot_command
    assert copilot["version"] == 1
    assert copilot_entry["hooks"][0]["timeout"] == 5
