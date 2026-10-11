"""Tests for the koopa plugin env-file guard (plugins/koopa/hooks/guard_env_files.py).

The guard blocks reads and edits of `.env` and `.env.local`, through the file tools and
through shell commands, and lets a command load the file with `source` or `load_dotenv`.

Safety: the commands are payload text; no test executes them. The hook is run as a
subprocess, so nothing it prints leaks into the test process.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

_HOOK = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks" / "guard_env_files.py"

BLOCKED = [
    "cat .env",
    "cat .env.local",
    "cat ./.env",
    "cat /home/jdoe42/app/.env",
    "ls .env",
    "grep KEY .env",
    "python3 -c \"open('.env').read()\"",
    "source .env && cat .env",
    "echo x >> .env",
    "cat 'app/.env'",
    "head -1 .env; echo done",
]

ALLOWED = [
    "ls",
    "cat .envrc",
    "cat .env.example",
    "cat .env.local.bak",
    "ls .venv/bin",
    "ls .env/bin/activate",
    "cat my.env",
    "source .env",
    "set -a && source .env && set +a",
    ". ./.env",
    "cd app; source ../.env; pytest",
    "python3 -c 'from dotenv import load_dotenv; load_dotenv()'",
    "python3 -c \"load_dotenv('.env')\"",
]


def _run(stdin: str) -> subprocess.CompletedProcess[str]:
    """Run the real hook entry; a nonzero exit is returned, not raised."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_HOOK)],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def _bash(command: str) -> str:
    """A Claude Code Bash payload."""
    return json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})


def _file(tool: str, path: str) -> str:
    """A Claude Code file-tool payload."""
    return json.dumps({"tool_name": tool, "tool_input": {"file_path": path, "content": "x"}})


@pytest.mark.parametrize("command", BLOCKED)
def test_shell_commands_naming_an_env_file_are_blocked(command: str) -> None:
    """A shell command that names an env file other than to load it exits 2."""
    result = _run(_bash(command))
    assert result.returncode == 2
    assert "Blocked" in result.stderr
    assert result.stdout == ""


@pytest.mark.parametrize("command", ALLOWED)
def test_other_names_and_loading_forms_pass(command: str) -> None:
    """Look-alike names and the source or load_dotenv forms exit 0 silently."""
    result = _run(_bash(command))
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


@pytest.mark.parametrize("tool", ["Edit", "Write", "Read"])
@pytest.mark.parametrize("path", ["/work/app/.env", "/work/app/.env.local", ".env"])
def test_file_tools_on_an_env_file_are_blocked(tool: str, path: str) -> None:
    """Edit, Write and Read on an env file exit 2."""
    result = _run(_file(tool, path))
    assert result.returncode == 2
    assert "credentials" in result.stderr


@pytest.mark.parametrize("path", ["/work/app/.envrc", "/work/app/.env.example", "/w/app/main.py"])
def test_file_tools_on_other_files_pass(path: str) -> None:
    """Other file names exit 0."""
    assert _run(_file("Write", path)).returncode == 0


def test_copilot_view_shape_is_blocked() -> None:
    """Copilot's `view` keys the path as `path`."""
    payload = json.dumps({"tool_name": "view", "tool_input": {"path": "/work/app/.env"}})
    assert _run(payload).returncode == 2


def test_copilot_batched_shell_call_is_blocked() -> None:
    """A batched Copilot payload is unwrapped: the second command names an env file."""
    payload = json.dumps(
        {"toolCalls": [{"args": {"command": "ls"}}, {"args": {"command": "cat .env"}}]}
    )
    result = _run(payload)
    assert result.returncode == 2
    assert "shell command" in result.stderr


def test_copilot_batched_clean_calls_pass() -> None:
    """A batched Copilot payload with no env file exits 0."""
    payload = json.dumps({"toolCalls": [{"args": {"command": "ls"}}, {"args": {"path": "/a.py"}}]})
    assert _run(payload).returncode == 0


def test_apply_patch_envelope_naming_an_env_file_is_blocked() -> None:
    """Copilot's apply_patch string envelope is parsed per file."""
    patch = "*** Begin Patch\n*** Add File: /w/app/.env\n+KEY=1\n*** End Patch"
    payload = json.dumps({"tool_name": "apply_patch", "tool_input": patch})
    assert _run(payload).returncode == 2


@pytest.mark.parametrize("stdin", ["", "   \n", "not json", "[]", "3"])
def test_empty_or_malformed_stdin_exits_zero(stdin: str) -> None:
    """No inspectable payload means nothing to guard: exit 0 with no output."""
    result = _run(stdin)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


@pytest.mark.parametrize("payload", [{"tool_input": {}}, {"tool_input": {"command": 5}}, {}])
def test_payloads_with_nothing_to_inspect_exit_zero(payload: dict) -> None:
    """A well-formed payload with no file path or command string is not blocked."""
    assert _run(json.dumps(payload)).returncode == 0


@pytest.mark.parametrize("payload", [{"tool_input": {"file_path": 5}}, {"tool_input": 3}])
def test_unreadable_file_input_is_denied(payload: dict) -> None:
    """A tool_input the adapter cannot read fails closed: a credential check must not pass."""
    result = _run(json.dumps(payload))
    assert result.returncode == 2
    assert "invalid file-hook input" in result.stderr


def test_internal_error_is_denied(tmp_path: Path) -> None:
    """An unexpected exception in the entry denies instead of letting a traceback through."""
    runner = tmp_path / "run_hook.py"
    runner.write_text(
        "import runpy, sys\n"
        "import hook_adapter\n"
        "def boom(raw):\n"
        "    raise RuntimeError('x')\n"
        "hook_adapter.targets_or_deny = boom\n"
        f"sys.argv = [{str(_HOOK)!r}]\n"
        f"runpy.run_path({str(_HOOK)!r}, run_name='__main__')\n",
        encoding="utf-8",
    )
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1", "PYTHONPATH": str(_HOOK.parent)}
    with pytest.raises(subprocess.CalledProcessError) as caught:
        subprocess.run(
            [sys.executable, "-B", str(runner)],
            input="{}",
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    assert caught.value.returncode == 2
    assert "internal error" in caught.value.stderr
