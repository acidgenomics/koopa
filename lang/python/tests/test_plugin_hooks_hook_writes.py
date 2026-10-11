"""Tests for the koopa plugin hook-write guard (plugins/koopa/hooks/guard_hook_writes.py).

The guard forces an approval prompt when a Bash command writes a guard hook or a
`settings.json` file. Broad allow rules such as `Bash(sed:*)` would let that run
silently. Reads, running a hook, and editing the chezmoi source must stay quiet.

Two lists drive the file. ASKS must prompt (a regression there reopens the quiet
edit path). QUIET must not (a regression there adds noise to routine work).

Safety: the commands are payload text that `should_ask` reads; no test executes them.
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

guard_hook_writes = importlib.import_module("guard_hook_writes")
should_ask = guard_hook_writes.should_ask

_GUARD = _HOOKS_DIR / "guard_hook_writes.py"

ASKS = [
    "sed -i 's/a/b/' ~/.agents/hooks/guard_rm.py",
    "gsed -i s/a/b/ $HOME/.agents/hooks/guard_rm.py",
    "sed -i.bak s/a/b/ /Users/someone/.agents/hooks/guard_rm.py",
    "sed -ni s/a/b/p ~/.claude/hooks/guard_rm.py",
    "perl -pi -e 's/a/b/' ~/.agents/hooks/guard_rm.py",
    "echo x > ~/.agents/hooks/guard_rm.py",
    "echo x >> ~/.claude/hooks/guard_rm.py",
    "echo x >| ~/.agents/hooks/guard_rm.py",
    "echo x 2>~/.agents/hooks/log",
    "cat > ~/.claude/settings.json <<'EOF'\n{}\nEOF",
    "tee ~/.agents/hooks/guard_rm.py",
    "echo x | tee -a ~/.claude/settings.json",
    "mv ~/.agents/hooks/guard_rm.py $TMPDIR/x",
    "mv $TMPDIR/x ~/.agents/hooks/guard_rm.py",
    "cp $TMPDIR/x ~/.agents/hooks/guard_rm.py",
    "cp -f $TMPDIR/x ~/.agents/hooks/",
    "install -m 755 $TMPDIR/x ~/.agents/hooks/guard_rm.py",
    "ln -sf $TMPDIR/x ~/.agents/hooks/guard_rm.py",
    "rm ~/.agents/hooks/guard_rm.py",
    "rm -rf ~/.agents/hooks",
    "chmod 000 ~/.agents/hooks/guard_rm.py",
    "touch ~/.agents/hooks/new.py",
    "truncate -s 0 ~/.claude/settings.local.json",
    "python3 -c \"open('/Users/someone/.agents/hooks/x.py', 'w').write('')\"",
    "python3 - <<'EOF'\nfrom pathlib import Path\nPath('~/.agents/hooks/x.py').write_text('')\nEOF",
    "cd ~/.agents/hooks && sed -i s/a/b/ guard_rm.py",
    "pushd ~/.agents/hooks; rm guard_rm.py",
    "cd ~/.claude/hooks && echo x > guard_rm.py",
    "bash -c 'sed -i s/a/b/ ~/.agents/hooks/guard_rm.py'",
    "sudo sed -i s/a/b/ ~/.agents/hooks/guard_rm.py",
    "ls && sed -i s/a/b/ .agents/hooks/guard_rm.py",
    "sed -i s/a/b/ .claude/settings.json",
]

QUIET = [
    "cat ~/.agents/hooks/guard_rm.py",
    "ls -la ~/.agents/hooks",
    "grep -n rm ~/.agents/hooks/guard_rm.py",
    "cmp ~/.agents/hooks/guard_rm.py $TMPDIR/x",
    "diff ~/.agents/hooks/guard_rm.py $TMPDIR/x",
    "sed -n 1,20p ~/.agents/hooks/guard_rm.py",
    "sed s/a/b/ ~/.agents/hooks/guard_rm.py",
    "cp ~/.agents/hooks/guard_rm.py $TMPDIR/copy.py",
    "rsync -a ~/.agents/hooks/ $TMPDIR/backup/",
    "python3 ~/.agents/hooks/guard_rm.py",
    "bash ~/.agents/hooks/guard-installs.sh",
    "pytest tests/test_guard_rm.py",
    "chezmoi --force apply ~/.agents/hooks/guard_rm.py",
    "chezmoi diff ~/.claude/settings.json",
    "sed -i s/a/b/ chezmoi/dot_agents/hooks/guard_rm.py",
    "echo x > chezmoi/dot_agents/hooks/guard_rm.py",
    "echo x > $TMPDIR/out.txt",
    "sed -i s/a/b/ $TMPDIR/file",
    "cd ~/.agents/hooks && ls",
    "cd ~/.agents/hooks && python3 guard_rm.py",
    "python3 -c \"print(open('/Users/someone/.agents/hooks/x.py').read())\"",
    "python3 -c \"open('/etc/hosts', 'w')\"",
    "echo 'sed -i x ~/.agents/hooks/y'",
    "git commit -m 'sed -i the hooks in ~/.agents/hooks'",
    "ls",
    "",
]


@pytest.mark.parametrize("command", ASKS)
def test_hook_and_settings_writes_ask(command: str) -> None:
    """Hook and settings writes ask."""
    assert should_ask(command), command


@pytest.mark.parametrize("command", QUIET)
def test_reads_runs_and_source_edits_stay_quiet(command: str) -> None:
    """Reads runs and source edits stay quiet."""
    assert not should_ask(command), command


def test_an_unparsable_command_stays_quiet() -> None:
    """An unparsable command stays quiet."""
    assert not should_ask("sed -i 'unterminated ~/.agents/hooks/x")


def _run(payload: object, harness: str = "") -> subprocess.CompletedProcess:
    """Run the real hook entry; a nonzero exit is returned, not raised."""
    env = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1"}
    env.pop("AGENT_HOOK_HARNESS", None)
    if harness:
        env["AGENT_HOOK_HARNESS"] = harness
    raw = payload if isinstance(payload, str) else json.dumps(payload)
    try:
        return subprocess.run(
            [sys.executable, "-B", str(_GUARD)],
            input=raw,
            capture_output=True,
            text=True,
            env=env,
            check=True,
        )
    except subprocess.CalledProcessError as error:
        return subprocess.CompletedProcess(error.cmd, error.returncode, error.stdout, error.stderr)


def test_hook_prints_an_ask_in_the_claude_shape() -> None:
    """Hook prints an ask in the claude shape."""
    result = _run({"tool_input": {"command": "sed -i s/a/b/ ~/.agents/hooks/guard_rm.py"}})
    assert result.returncode == 0
    output = json.loads(result.stdout)["hookSpecificOutput"]
    assert output["permissionDecision"] == "ask"
    assert "chezmoi" in output["permissionDecisionReason"]


def test_hook_prints_a_bare_ask_for_copilot() -> None:
    """Hook prints a bare ask for copilot."""
    payload = {"tool_input": {"command": "rm ~/.agents/hooks/guard_rm.py"}}
    output = json.loads(_run(payload, harness="copilot").stdout)
    assert output["permissionDecision"] == "ask"
    assert "hookSpecificOutput" not in output


def test_hook_reads_a_batched_copilot_payload() -> None:
    """Hook reads a batched copilot payload."""
    payload = {
        "toolCalls": [
            {"args": {"command": "ls"}},
            {"args": {"command": "echo x > ~/.claude/settings.json"}},
        ]
    }
    assert "ask" in _run(payload).stdout


def test_hook_stays_silent_for_a_clean_command() -> None:
    """Hook stays silent for a clean command."""
    result = _run({"tool_input": {"command": "cat ~/.agents/hooks/guard_rm.py"}})
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


@pytest.mark.parametrize("stdin", ["", "not json", "[]", '{"tool_input": 3}', '{"tool_input": {}}'])
def test_hook_fails_open_on_bad_input(stdin: str) -> None:
    """Hook fails open on bad input."""
    result = _run(stdin)
    assert (result.returncode, result.stdout) == (0, "")
