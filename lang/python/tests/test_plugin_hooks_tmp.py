"""Tests for the koopa plugin's /tmp guard (plugins/koopa/hooks/guard_tmp.py).

The guard denies tool calls that would create or write under /tmp, /var/tmp, or
/dev/shm and tells the model to use ``mktemp`` (which honors $TMPDIR).

Two lists drive the file. DENIED must stay blocked (a regression there lets scratch
files back into /tmp). PASSES must reach the normal permission flow (a regression
there brings back false positives on reads, ``mktemp``, and $TMPDIR paths).

Safety: nothing is written. Commands such as ``echo hi > /tmp/x`` are payload text
that the decision functions read; no test executes them. $TMPDIR is always passed
explicitly (a fake directory inside ``tmp_path``), never taken from the ambient
environment.
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

guard_tmp = importlib.import_module("guard_tmp")
decide_bash = guard_tmp.decide_bash
decide_file = guard_tmp.decide_file

_ENTRY = _HOOKS_DIR / "guard_tmp.py"


def _run_entry(stdin: str, tmpdir: str) -> subprocess.CompletedProcess:
    """Run the real hook entry with an explicit TMPDIR; a nonzero exit is returned, not raised."""
    env = {**os.environ, "TMPDIR": tmpdir, "PYTHONDONTWRITEBYTECODE": "1"}
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


@pytest.fixture
def tmpdir_root(tmp_path: Path) -> str:
    """A fake per-user $TMPDIR outside /tmp, plus a symlink inside it that points at /tmp."""
    root = tmp_path / "T"
    root.mkdir()
    (root / "to_tmp").symlink_to("/tmp")
    return str(root.resolve())


DENIED = [
    "cat > /tmp/x <<'EOF'\nhi\nEOF",
    "echo hi >/tmp/x",
    "echo hi > /tmp/x",
    "echo hi >> /tmp/x",
    "echo hi 2>/tmp/err",
    "echo hi &>/tmp/both",
    "ls > /tmp/listing",
    "tee /tmp/x",
    "mktemp -d /tmp/x.XXXX",
    "mktemp /tmp/f.XXXX",
    "mktemp -p /tmp",
    "mktemp --tmpdir=/tmp",
    "mkdir -p /tmp/work",
    "touch /tmp/x",
    "cp a /tmp/b",
    "cp -t /tmp a b",
    "cp --target-directory=/tmp a b",
    "mv a /var/tmp/b",
    "cp a /private/tmp/b",
    "cp a /tmp/../tmp/b",
    "cp a {root}/to_tmp/b",
    "curl -o /tmp/x http://h",
    "wget -O /tmp/x http://h",
    "dd if=a of=/tmp/x",
    "cd /tmp && ls",
    "pushd /tmp",
    "env FOO=1 touch /tmp/x",
    "sudo cp a /tmp/b",
    "bash -c 'echo hi > /tmp/x'",
    "python3 -c \"open('/tmp/x','w').write('a')\"",
    "python3 - <<'EOF'\nimport pathlib\npathlib.Path('/tmp/x').write_text('a')\nEOF",
    "cat /tmp/a > /tmp/b",
    "echo hi > /dev/shm/x",
    "find /tmp -name x -delete",
]

PASSES = [
    "mktemp",
    "mktemp -d",
    "mktemp -t abc",
    'mktemp -d "$TMPDIR/x.XXXX"',
    "cp a $TMPDIR/b",
    "cp /tmp/a b",
    "mv /tmp/a ./a",
    "ls /tmp",
    "ls -la /var/tmp",
    "cat /tmp/x",
    "cat < /tmp/x",
    "python3 job.py < /tmp/in",
    "grep x /tmp/y | wc -l",
    "head -n 5 /tmp/x",
    "rm /tmp/x",
    "rm -r /tmp/x",
    "rmdir /tmp/x",
    "find /tmp -name x",
    'echo "see /tmp/x"',
    "echo /tmp/x",
    "echo hi > {root}/out",
    "cp a {root}/b",
    "mkdir -p {root}/work",
    "cat > {root}/x <<'EOF'\nhi\nEOF",
    "echo hi > out.txt",
    "ls",
    "git status",
    "python3 -c \"print('/tmp is shared')\"",
    "python3 -c \"print(open('/tmp/x').read())\"",
]


@pytest.mark.parametrize("template", DENIED)
def test_denied(template: str, tmpdir_root: str) -> None:
    """Denied."""
    command = template.replace("{root}", tmpdir_root)
    assert decide_bash(command, tmpdir_root), command


@pytest.mark.parametrize("template", PASSES)
def test_passes(template: str, tmpdir_root: str) -> None:
    """Passes."""
    command = template.replace("{root}", tmpdir_root)
    assert decide_bash(command, tmpdir_root) is None, command


@pytest.mark.parametrize("path", ["/tmp/x", "/private/tmp/x", "/var/tmp/x", "{root}/to_tmp/x"])
def test_file_tools_are_denied_under_tmp(path: str, tmpdir_root: str) -> None:
    """File tools are denied under tmp."""
    assert decide_file(path.replace("{root}", tmpdir_root), tmpdir_root)


@pytest.mark.parametrize("path", ["{root}/x", "/Users/someone/repo/file.py", "relative.txt", ""])
def test_file_tools_pass_elsewhere(path: str, tmpdir_root: str) -> None:
    """File tools pass elsewhere."""
    assert decide_file(path.replace("{root}", tmpdir_root), tmpdir_root) is None


@pytest.mark.parametrize("inactive", ["", "relative/dir", "/tmp", "/private/tmp", "/var/tmp/x"])
def test_guard_is_inactive_when_tmpdir_is_unset_or_under_tmp(inactive: str) -> None:
    """Guard is inactive when tmpdir is unset or under tmp."""
    assert decide_bash("echo hi > /tmp/x", inactive) is None
    assert decide_file("/tmp/x", inactive) is None


def test_an_unparsable_command_is_left_to_the_normal_flow(tmpdir_root: str) -> None:
    """An unparsable command is left to the normal flow."""
    assert decide_bash("echo 'unterminated > /tmp/x", tmpdir_root) is None


def _hook(payload: dict, tmpdir: str) -> subprocess.CompletedProcess:
    return _run_entry(json.dumps(payload), tmpdir)


def test_hook_blocks_a_bash_write_with_exit_2_and_mentions_mktemp(tmpdir_root: str) -> None:
    """Hook blocks a bash write with exit 2 and mentions mktemp."""
    result = _hook(
        {"tool_name": "Bash", "tool_input": {"command": "echo hi > /tmp/x"}}, tmpdir_root
    )
    assert result.returncode == 2
    assert "mktemp" in json.loads(result.stderr)["reason"]


def test_hook_blocks_a_write_tool_call(tmpdir_root: str) -> None:
    """Hook blocks a write tool call."""
    payload = {"tool_name": "Write", "tool_input": {"file_path": "/tmp/x", "content": "a"}}
    assert _hook(payload, tmpdir_root).returncode == 2


def test_hook_ignores_other_tools(tmpdir_root: str) -> None:
    """Hook ignores other tools."""
    payload = {"tool_name": "Read", "tool_input": {"file_path": "/tmp/x"}}
    result = _hook(payload, tmpdir_root)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


def test_hook_stays_silent_for_a_clean_command(tmpdir_root: str) -> None:
    """Hook stays silent for a clean command."""
    payload = {"tool_name": "Bash", "tool_input": {"command": f"echo hi > {tmpdir_root}/x"}}
    result = _hook(payload, tmpdir_root)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


@pytest.mark.parametrize("stdin", ["", "not json", "[]", '{"tool_name": "Bash"}'])
def test_hook_fails_toward_no_decision_on_bad_input(stdin: str, tmpdir_root: str) -> None:
    """Hook fails toward no decision on bad input."""
    result = _run_entry(stdin, tmpdir_root)
    assert (result.returncode, result.stdout) == (0, "")


MORE_DENIED = [
    "echo hi >| /tmp/x",
    "echo hi >|/tmp/x",
    "curl -o/tmp/x http://h",
    "tar -xf a.tar -C/tmp",
    "tar -xf a.tar -C /tmp",
    "tar --directory=/tmp -xf a.tar",
    "tar -czf /tmp/a.tgz dir",
    "tar czf /tmp/a.tgz dir",
    "unzip a.zip -d /tmp/out",
    "TMPDIR=/tmp mktemp -d",
    "D=/tmp; mkdir $D/x",
    "D=/tmp/w; touch ${D}/f",
    "D=/tmp; cd $D",
    "git clone http://h/r /tmp/r",
    "sed -i s/a/b/ /tmp/f",
    "sort -o /tmp/out in.txt",
    "timeout 5 touch /tmp/x",
    "poetry run python -c \"open('/tmp/x', 'w').write('a')\"",
    "pixi run python -c \"import os; os.rename('a', '/tmp/b')\"",
    "python3 -c \"df.to_excel('/tmp/x.xlsx')\"",
    "python3 -c \"urllib.request.urlretrieve(u, '/tmp/x')\"",
    "python3 -c \"zipfile.ZipFile('a').extractall('/tmp/x')\"",
]

MORE_PASSES = [
    "sort /tmp/f",
    "awk '{print $1}' /tmp/f",
    "sed s/a/b/ /tmp/f",
    "cut -d, -f1 /tmp/f",
    "tar -tf /tmp/a.tar",
    "tar -xf /tmp/a.tar",
    "unzip -l /tmp/a.zip",
    "unzip /tmp/a.zip",
    "python3 /tmp/x.py",
    "bash /tmp/x.sh",
    "source /tmp/env.sh",
    "git -C /tmp log",
    "git -C /tmp status",
    "timeout 5 cat /tmp/x",
    "sudo -u root cat /tmp/x",
    "nice -n 5 ls /tmp",
    "FOO=/tmp/x cat $FOO",
    "python3 -c \"print(open('/tmp/x').read())\"",
    'python3 -c "# write notes to /tmp\nprint(1)"',
    "poetry run python -c \"print(open('/tmp/x').read())\"",
]


@pytest.mark.parametrize("template", MORE_DENIED)
def test_more_denied(template: str, tmpdir_root: str) -> None:
    """More denied."""
    assert decide_bash(template, tmpdir_root), template


@pytest.mark.parametrize("template", MORE_PASSES)
def test_more_passes(template: str, tmpdir_root: str) -> None:
    """More passes."""
    assert decide_bash(template, tmpdir_root) is None, template


def test_hook_reads_a_batched_copilot_payload(tmpdir_root: str) -> None:
    """Hook reads a batched copilot payload."""
    payload = {"toolCalls": [{"args": {"command": "ls"}}, {"args": {"command": "touch /tmp/x"}}]}
    assert _hook(payload, tmpdir_root).returncode == 2


@pytest.mark.parametrize(
    "payload",
    [
        {"tool_name": "create", "tool_input": {"path": "/tmp/x", "file_text": "a"}},
        {"tool_name": "NotebookEdit", "tool_input": {"notebook_path": "/tmp/n.ipynb"}},
        {"toolCalls": [{"toolName": "edit", "args": {"path": "/tmp/x", "new_str": "a"}}]},
        {
            "tool_name": "apply_patch",
            "tool_input": "*** Begin Patch\n*** Add File: /tmp/x\n+a\n*** End Patch",
        },
    ],
)
def test_hook_denies_copilot_shaped_file_writes(payload: dict, tmpdir_root: str) -> None:
    """Hook denies copilot shaped file writes."""
    assert _hook(payload, tmpdir_root).returncode == 2


def test_hook_does_not_deny_a_copilot_read(tmpdir_root: str) -> None:
    """Hook does not deny a copilot read."""
    payload = {"tool_name": "view", "tool_input": {"path": "/tmp/x"}}
    assert _hook(payload, tmpdir_root).returncode == 0
