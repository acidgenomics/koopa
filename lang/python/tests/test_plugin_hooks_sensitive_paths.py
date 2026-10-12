"""Tests for the koopa plugin sensitive-path guard (plugins/koopa/hooks/guard_sensitive_paths.py).

The guard asks (never denies) when a Bash command references `~/Documents` or `~/Downloads`.
Exemptions come from the git config key `koopa.allowedPaths` and are empty by default.

Safety: the commands are payload text; no test executes them. Each test isolates git
configuration with `GIT_CONFIG_GLOBAL` pointing at a file under `tmp_path`,
`GIT_CONFIG_SYSTEM=/dev/null`, and a `HOME` under `tmp_path`, so the real user and system
config are never read. All names are made-up placeholders.
"""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

_HOOK = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks" / "guard_sensitive_paths.py"

ASKS = [
    "ls ~/Documents",
    "ls ~/Documents/",
    "cat ~/Documents/plan.md",
    "cat $HOME/Documents/plan.md",
    "cat ${HOME}/Documents/plan.md",
    "cat /Users/jdoe42/Documents/plan.md",
    "ls ~/Downloads",
    "cp ~/Downloads/a.zip .",
    "cat '~/Documents/x'",
    'ls "$HOME/Documents"',
    "cd ~/Documents; ls",
    "ls ~/Documents&&ls",
    "echo hi | ls ~/Documents|cat",
    "ls\nls ~/Documents",
    "ls ~/Documents/notes",
    "ls ~/Documents/notes-old",
]

QUIET = [
    "ls",
    "ls ./MyDocuments",
    "ls ~/MyDocuments/x",
    "ls /opt/Users/jdoe42/Documents",
    "ls ~/Documents-old",
    "ls ~/Documentsx",
    "ls ~/Downloads2",
    "ls ~/src/Documents/x",
    "ls ~/.local/Documents",
    "ls /tmp/Documents",
    "echo Documents Downloads",
    "ls /Users/jdoe42/src",
]

EXEMPT_CONFIG = "[koopa]\n\tallowedPaths = Documents/notes\n\tallowedPaths = Documents/tasks\n"

EXEMPT = [
    "ls ~/Documents/notes",
    "ls ~/Documents/notes/",
    "cat ~/Documents/notes/a.md",
    "cat $HOME/Documents/notes/a.md",
    "cat ${HOME}/Documents/tasks/list.txt",
    "cat /Users/jdoe42/Documents/notes/a.md",
    'cat "~/Documents/notes/a b.md"',
    "cd ~/Documents/notes; ls",
    "ls ~/Documents/notes ~/Documents/tasks",
    "ls ~/Documents/notes ~/Documents/notes",
]

STILL_ASK = [
    "ls ~/Documents/notes-old",
    "ls ~/Documents/notesx",
    "ls ~/Documents/other",
    "ls ~/Documents",
    "ls ~/Documents/notes ~/Documents",
    "ls ~/Documents/notes ~/Documents/other",
    "ls ~/Documents/notes ~/Downloads",
    "ls ~/Downloads/notes",
    "cat ~/Documents/notes/../secret.txt",
    "cat ~/Documents/notes/sub/../../secret.txt",
]


def _env(tmp_path: Path, config: str = "", harness: str = "") -> dict[str, str]:
    """Build a subprocess environment whose git config comes only from `config`."""
    home = tmp_path / "home"
    home.mkdir(parents=True, exist_ok=True)
    global_config = tmp_path / "gitconfig"
    global_config.write_text(config, encoding="utf-8")
    env = {k: v for k, v in os.environ.items() if not k.startswith(("GIT_", "AGENT_HOOK"))}
    env.update(
        {
            "HOME": str(home),
            "XDG_CONFIG_HOME": str(home / ".config"),
            "GIT_CONFIG_GLOBAL": str(global_config),
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "PYTHONDONTWRITEBYTECODE": "1",
        }
    )
    if harness:
        env["AGENT_HOOK_HARNESS"] = harness
    return env


def _run(stdin: str, env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    """Run the real hook entry; a nonzero exit is returned, not raised."""
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


def _asks(command: str, env: dict[str, str]) -> bool:
    """True when the hook prints an ask for the command; exit status is always 0."""
    result = _run(_bash(command), env)
    assert result.returncode == 0
    if not result.stdout:
        return False
    assert json.loads(result.stdout)["hookSpecificOutput"]["permissionDecision"] == "ask"
    return True


@pytest.mark.parametrize("command", ASKS)
def test_protected_paths_ask_with_no_config(command: str, tmp_path: Path) -> None:
    """With no config nothing is exempt, so every reference asks (even the sample folders)."""
    assert _asks(command, _env(tmp_path))


@pytest.mark.parametrize("command", QUIET)
def test_look_alike_paths_stay_quiet(command: str, tmp_path: Path) -> None:
    """Boundary rules: a longer name, a nested folder, or another root passes silently."""
    result = _run(_bash(command), _env(tmp_path))
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


@pytest.mark.parametrize("command", EXEMPT)
def test_allowed_paths_are_exempt(command: str, tmp_path: Path) -> None:
    """A path at or under a `koopa.allowedPaths` value passes, in every home spelling."""
    assert not _asks(command, _env(tmp_path, EXEMPT_CONFIG))


@pytest.mark.parametrize("command", STILL_ASK)
def test_exemption_matches_only_at_a_path_segment_boundary(command: str, tmp_path: Path) -> None:
    """A sibling, a parent, Downloads, `..` climbing, or one non-exempt hit still asks."""
    assert _asks(command, _env(tmp_path, EXEMPT_CONFIG))


def test_the_exemption_key_changes_the_outcome(tmp_path: Path) -> None:
    """The same command asks without the key and passes with it."""
    command = "cat ~/Documents/notes/a.md"
    assert _asks(command, _env(tmp_path / "a"))
    assert not _asks(command, _env(tmp_path / "b", EXEMPT_CONFIG))


def test_allowed_path_with_slashes_and_whitespace_is_normalised(tmp_path: Path) -> None:
    """Leading and trailing slashes and surrounding spaces in the value are ignored."""
    env = _env(tmp_path, "[koopa]\n\tallowedPaths = /Documents/notes/ \n")
    assert not _asks("ls ~/Documents/notes/x", env)
    assert _asks("ls ~/Documents/notes-old", env)


def test_allowed_path_may_name_a_downloads_subfolder(tmp_path: Path) -> None:
    """A value under Downloads exempts that subfolder only."""
    env = _env(tmp_path, "[koopa]\n\tallowedPaths = Downloads/inbox\n")
    assert not _asks("ls ~/Downloads/inbox/a.zip", env)
    assert _asks("ls ~/Downloads", env)
    assert _asks("ls ~/Downloads/inbox2", env)


@pytest.mark.parametrize(
    "value", ["", "src/Documents", "Documentsx", "../Documents", "Documents/../x", "~/Documents/x"]
)
def test_unusable_values_exempt_nothing(value: str, tmp_path: Path) -> None:
    """A value outside Documents or Downloads, or one that climbs, is ignored."""
    env = _env(tmp_path, f"[koopa]\n\tallowedPaths = {value}\n")
    assert _asks("ls ~/Documents/x", env)


def test_claude_output_shape(tmp_path: Path) -> None:
    """Claude Code gets the decision wrapped in hookSpecificOutput."""
    result = _run(_bash("ls ~/Documents"), _env(tmp_path))
    output = json.loads(result.stdout)
    assert list(output) == ["hookSpecificOutput"]
    inner = output["hookSpecificOutput"]
    assert inner["hookEventName"] == "PreToolUse"
    assert inner["permissionDecision"] == "ask"
    assert "~/Documents" in inner["permissionDecisionReason"]


def test_copilot_output_shape(tmp_path: Path) -> None:
    """With AGENT_HOOK_HARNESS=copilot the decision is a bare top-level object."""
    result = _run(_bash("ls ~/Downloads"), _env(tmp_path, harness="copilot"))
    output = json.loads(result.stdout)
    assert output["permissionDecision"] == "ask"
    assert "permissionDecisionReason" in output
    assert "hookSpecificOutput" not in output


def test_copilot_batched_payload_is_read(tmp_path: Path) -> None:
    """Copilot's toolCalls batch is unwrapped: the second command asks."""
    payload = json.dumps(
        {"toolCalls": [{"args": {"command": "ls"}}, {"args": {"command": "ls ~/Documents"}}]}
    )
    output = json.loads(_run(payload, _env(tmp_path, harness="copilot")).stdout)
    assert output["permissionDecision"] == "ask"


def test_copilot_batched_exempt_payload_stays_quiet(tmp_path: Path) -> None:
    """A batch whose only reference is exempt prints nothing."""
    payload = json.dumps({"toolCalls": [{"args": {"command": "ls ~/Documents/notes"}}]})
    result = _run(payload, _env(tmp_path, EXEMPT_CONFIG, harness="copilot"))
    assert (result.returncode, result.stdout) == (0, "")


@pytest.mark.parametrize(
    "stdin", ["", "  \n", "not json", "[]", "3", '{"tool_input": 3}', '{"tool_input": {}}']
)
def test_empty_or_malformed_stdin_fails_open(stdin: str, tmp_path: Path) -> None:
    """No readable command means no opinion: exit 0 with no output."""
    result = _run(stdin, _env(tmp_path))
    assert (result.returncode, result.stdout) == (0, "")


def test_missing_git_means_nothing_is_exempt_but_it_still_asks(tmp_path: Path) -> None:
    """With git absent from PATH the config reads empty, so the exempt path asks."""
    env = _env(tmp_path, EXEMPT_CONFIG)
    env["PATH"] = str(tmp_path / "empty-bin")
    result = _run(_bash("ls ~/Documents/notes"), env)
    assert result.returncode == 0
    assert json.loads(result.stdout)["hookSpecificOutput"]["permissionDecision"] == "ask"


def test_internal_error_fails_open(tmp_path: Path) -> None:
    """An unexpected exception while judging a command exits 0 with no output."""
    runner = tmp_path / "run_hook.py"
    runner.write_text(
        "import runpy\n"
        "import hook_adapter\n"
        "def boom(payload):\n"
        "    raise RuntimeError('x')\n"
        "hook_adapter.read_commands = boom\n"
        f"runpy.run_path({str(_HOOK)!r}, run_name='__main__')\n",
        encoding="utf-8",
    )
    env = _env(tmp_path)
    env["PYTHONPATH"] = str(_HOOK.parent)
    result = subprocess.run(
        [sys.executable, "-B", str(runner)],
        input=_bash("ls ~/Documents"),
        capture_output=True,
        text=True,
        check=True,
        env=env,
    )
    assert (result.returncode, result.stdout) == (0, "")
