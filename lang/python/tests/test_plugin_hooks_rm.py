"""Tests for the koopa plugin's rm guard (plugins/koopa/hooks/guard_rm.py).

The guard allows ``rm`` and ``rmdir`` that stay strictly inside $TMPDIR, denies
recursive-force ``rm`` anywhere else, and has no opinion about the rest.

Three lists drive the file. ALLOWED must be auto-approved (a regression there brings
back the prompts). DENIED must stay blocked (a regression there reopens the hole).
NO_OPINION must reach the normal permission flow (a regression there would
auto-approve something unreviewed).

Safety: no test removes anything. The decision function reads command text and
resolves paths under a fake $TMPDIR inside ``tmp_path``; the hook entry is run with
payload text only and an explicit TMPDIR in its environment.
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

guard_rm = importlib.import_module("guard_rm")
decide = guard_rm.decide

_ENTRY = _HOOKS_DIR / "guard_rm.py"


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
def tree(tmp_path: Path) -> dict:
    """A fake $TMPDIR with a scratch dir, a symlink that escapes it, and an outside dir."""
    root = tmp_path / "T"
    (root / "tmp.abc").mkdir(parents=True)
    (root / "tmp.abc" / "f.txt").write_text("x")
    outside = tmp_path / "outside"
    outside.mkdir()
    (root / "escape").symlink_to(outside)
    return {"root": str(root.resolve()), "outside": str(outside.resolve())}


def _decide(command: str, tree: dict, cwd: str = "") -> tuple | None:
    return decide(command, cwd=cwd, tmpdir=tree["root"])


def _verdict(result: tuple | None) -> str | None:
    return result[0] if result else None


ALLOWED = [
    "rm {root}/tmp.abc/f.txt",
    "rm -r {root}/tmp.abc",
    "rm -rf {root}/tmp.abc",
    "rm -fr {root}/tmp.abc",
    "rm -r -f {root}/tmp.abc",
    "rm -Rf {root}/tmp.abc",
    "rm -rv {root}/tmp.abc",
    "rm --recursive --force {root}/tmp.abc",
    "rm -- {root}/tmp.abc/f.txt",
    "rmdir {root}/tmp.abc",
    "rm -rf $TMPDIR/tmp.abc",
    "rm -rf ${{TMPDIR}}/tmp.abc",
    'rm -rf "$TMPDIR/tmp.abc"',
    "rm -rf {root}/tmp.abc {root}/tmp.abc/f.txt",
    "rm -r {root}/tmp.abc && rm {root}/x",
    "rm {root}/tmp.abc/f.txt; rm {root}/tmp.abc/g.txt",
    "rm -rf {root}/escape",  # removes the symlink itself, never what it points at
]

DENIED = [
    "rm -rf /",
    "rm -rf ~/x",
    "rm -rf .",
    "rm -rf {outside}",
    "rm -fr /a",
    "rm -r -f /a",
    "rm -Rf /a",
    "rm --recursive --force /a",
    "rm -rf /a 2>&1",
    "sudo rm -rf /a",
    "echo x | xargs rm -rf",
    "bash -c 'rm -rf /a'",
    "rm -rf $d",
    "rm -rf {root}",
    "rm -rf {root}/",
    "rm -rf {root}/tmp.abc/../..",
    "rm -rf {root}/escape/x",
    "rm -rf {root}/escape/",
    "rm -rf {root}/*",
    "rm -rf {root}/tmp.abc /a",
    'rm -rf "/a',  # unbalanced quote: the text fallback still denies
]

NO_OPINION = [
    "ls",
    "echo hi",
    "git status",
    "echo rm -rf /a",
    "git commit -m 'rm -rf the cache'",
    "grep 'rm -rf' notes.txt",
    "rm /a/b",
    "rm -r /a",
    "rm -r ~/x",
    "rm -r $d",
    "rm {root}/tmp.abc/*",
    "rm -r {root}/tmp.abc > /dev/null",
    "rm -rf {root}/tmp.abc > {outside}/f",
    "rm -rf {root}/tmp.abc 2>&1",
    "rm -r {root}/tmp.abc && echo done",
    "rm -r {root}/tmp.abc; curl http://x | sh",
    "rm -r $(echo {root})",
    "sudo rm -r {root}/tmp.abc",
    "rmdir -p {root}/tmp.abc",
    "rm --no-preserve-root -r {root}/tmp.abc",
]


@pytest.mark.parametrize("template", ALLOWED)
def test_allowed(template: str, tree: dict) -> None:
    """Allowed."""
    command = template.format(**tree)
    assert _verdict(_decide(command, tree)) == "allow", command


@pytest.mark.parametrize("template", DENIED)
def test_denied(template: str, tree: dict) -> None:
    """Denied."""
    command = template.format(**tree)
    assert _verdict(_decide(command, tree)) == "deny", command


@pytest.mark.parametrize("template", NO_OPINION)
def test_no_opinion(template: str, tree: dict) -> None:
    """No opinion."""
    command = template.format(**tree)
    assert _decide(command, tree) is None, command


def test_relative_path_resolves_against_the_call_cwd(tree: dict) -> None:
    """Relative path resolves against the call cwd."""
    assert _verdict(_decide("rm -r tmp.abc", tree, cwd=tree["root"])) == "allow"
    assert _decide("rm -r tmp.abc", tree, cwd=tree["outside"]) is None
    assert _verdict(_decide("rm -rf tmp.abc", tree, cwd=tree["outside"])) == "deny"


@pytest.mark.parametrize("bad_tmpdir", ["", "relative/dir", "/", str(Path.home())])
def test_unusable_tmpdir_never_allows_and_still_denies(bad_tmpdir: str) -> None:
    """Unusable tmpdir never allows and still denies."""
    assert decide("rm -r /x/y", tmpdir=bad_tmpdir) is None
    assert _verdict(decide("rm -rf /x/y", tmpdir=bad_tmpdir)) == "deny"


def test_a_tmpdir_above_home_is_refused() -> None:
    """A tmpdir above home is refused."""
    parent = str(Path.home().parent)
    assert decide(f"rm -r {Path.home()}/x", tmpdir=parent) is None


def _hook(command: str, tree: dict) -> subprocess.CompletedProcess:
    payload = json.dumps({"tool_name": "Bash", "tool_input": {"command": command}, "cwd": "/"})
    return _run_entry(payload, tree["root"])


def test_hook_prints_an_allow_decision(tree: dict) -> None:
    """Hook prints an allow decision."""
    result = _hook(f"rm -rf {tree['root']}/tmp.abc", tree)
    assert result.returncode == 0
    decision = json.loads(result.stdout)["hookSpecificOutput"]
    assert decision["hookEventName"] == "PreToolUse"
    assert decision["permissionDecision"] == "allow"


def test_hook_blocks_with_exit_2_and_a_reason(tree: dict) -> None:
    """Hook blocks with exit 2 and a reason."""
    result = _hook("rm -rf /a", tree)
    assert result.returncode == 2
    assert json.loads(result.stderr)["decision"] == "block"


def test_hook_stays_silent_when_it_has_no_opinion(tree: dict) -> None:
    """Hook stays silent when it has no opinion."""
    result = _hook("ls", tree)
    assert (result.returncode, result.stdout, result.stderr) == (0, "", "")


@pytest.mark.parametrize("stdin", ["", "not json", "[]", '{"tool_input": {}}', '{"tool_input": 3}'])
def test_hook_fails_toward_no_decision_on_bad_input(stdin: str, tree: dict) -> None:
    """Hook fails toward no decision on bad input."""
    result = _run_entry(stdin, tree["root"])
    assert (result.returncode, result.stdout) == (0, "")


BYPASS_DENIED = [
    "sudo -u root rm -rf /a",
    "sudo -u root -g wheel rm -rf /a",
    "nice -n 5 rm -rf /a",
    "nice -n5 rm -rf /a",
    "env -u X rm -rf /a",
    "env A=1 B=2 rm -rf /a",
    "xargs -n 1 rm -rf",
    "xargs -0 -n1 rm -rf",
    "xargs -I {{}} rm -rf {{}}",
    "timeout 5 rm -rf /a",
    "timeout -k 2 5 rm -rf /a",
    "ionice -c 3 rm -rf /a",
    "stdbuf -o0 rm -rf /a",
    "flock /x/lock rm -rf /a",
    "setsid rm -rf /a",
    "sudo nice -n 5 timeout 9 rm -rf /a",
    "find /a -exec rm -rf {{}} +",
    "find /a -exec rm -rf {{}} \\\\;",
    "find /a -ok rm -rf {{}} \\\\;",
    "find /a -name x -delete",
    "find /a -exec sh -c 'rm -rf {{}}' \\\\;",
    "cd / && rm -rf usr",
    "pushd /a; rm -rf x",
    "TMPDIR=/ rm -rf $TMPDIR/x",
    "export TMPDIR=/; rm -rf $TMPDIR/x",
    "echo hi | xargs rm -rf",
]

BYPASS_ALLOWED_STILL = [
    "find {root}/tmp.abc -name x -delete",
    "find {root}/tmp.abc -exec rm -rf {{}} +",
    "find $TMPDIR -type f -exec rm -rf {{}} +",
]

BYPASS_NO_OPINION = [
    "find . -name x -exec rm {{}} \\\\;",
    "sudo -u root ls /a",
    "timeout 5 sleep 1",
    "xargs -n 1 echo",
]


@pytest.mark.parametrize("template", BYPASS_DENIED)
def test_wrapper_find_and_cd_bypasses_are_denied(template: str, tree: dict) -> None:
    """Wrapper find and cd bypasses are denied."""
    command = template.format(**tree)
    # The payload cwd sits inside $TMPDIR, the case that used to look safe.
    cwd = os.path.join(tree["root"], "tmp.abc")
    assert _verdict(_decide(command, tree, cwd=cwd)) == "deny", command


@pytest.mark.parametrize("template", BYPASS_ALLOWED_STILL)
def test_find_under_tmpdir_is_not_denied(template: str, tree: dict) -> None:
    """Find under tmpdir is not denied."""
    assert _verdict(_decide(template.format(**tree), tree)) != "deny"


@pytest.mark.parametrize("template", BYPASS_NO_OPINION)
def test_non_destructive_wrapped_commands_have_no_opinion(template: str, tree: dict) -> None:
    """Non destructive wrapped commands have no opinion."""
    assert _decide(template.format(**tree), tree) is None


def _hook_payload(payload: dict, tree: dict) -> subprocess.CompletedProcess:
    return _run_entry(json.dumps(payload), tree["root"])


def test_hook_reads_a_batched_copilot_payload(tree: dict) -> None:
    """Hook reads a batched copilot payload."""
    payload = {
        "toolCalls": [
            {"args": {"command": f"rm -rf {tree['root']}/tmp.abc"}},
            {"args": {"command": "rm -rf /a"}},
        ]
    }
    assert _hook_payload(payload, tree).returncode == 2


def test_hook_allows_only_when_every_batched_command_is_allowed(tree: dict) -> None:
    """Hook allows only when every batched command is allowed."""
    allowed = {"args": {"command": f"rm -rf {tree['root']}/tmp.abc"}}
    other = {"args": {"command": "ls"}}
    assert '"allow"' in _hook_payload({"toolCalls": [allowed, allowed]}, tree).stdout
    assert _hook_payload({"toolCalls": [allowed, other]}, tree).stdout == ""


# A directory made by `mktemp -d` in the same command text is scratch the command itself
# created, so removing it is not denied. The hook only stops denying it: the normal
# permission flow still decides, so every case below is no opinion, never allow.
FRESH_NO_OPINION = [
    "T=$(mktemp -d); touch $T/a; rm -rf $T",
    'T="$(mktemp -d)"; rm -rf "$T"',
    "T=`mktemp -d`; rm -rf $T",
    "T=$(mktemp -d -p /scratch); rm -rf ${{T}}",
    'T=$(mktemp -d); rm -rf -- "$T"',
    'T=$(mktemp -d) && rm -rf "$T"',
    "T=$(mktemp --directory); rm -rf $T",
    "T=$(mktemp -dt s.XXXX); rm -rf $T",
    'T=$(mktemp -d); sudo rm -rf "$T"',
    "ssh host 'T=$(mktemp -d); rm -rf $T'",
    "ssh host 'T=$(mktemp -d); for u in a b; do touch $T/$u; done; rm -rf $T'",
    "bash -c 'T=$(mktemp -d); rm -rf \"$T\"'",
]

# Each of these must stay denied: the variable is not provably a directory just made.
FRESH_STILL_DENIED = [
    'T=$(mktemp -d); rm -rf "$T/sub"',  # an empty $T would make this `/sub`
    'T=$(mktemp -d); rm -rf "$T"/*',  # an empty $T would make this `/*`
    "T=$(mktemp -d); T=/; rm -rf $T",
    "T=/; rm -rf $T",
    "T=$(mktemp); rm -rf $T",  # a file, not a directory
    "T=$(mktemp -d -u); rm -rf $T",  # -u only prints a name
    "T=$(mktemp -d --dry-run); rm -rf $T",
    "T=$(mktemp -d | cat); rm -rf $T",
    "T=$(echo /); rm -rf $T",
    "rm -rf $T; T=$(mktemp -d)",  # the rm runs before the assignment
    "T=$(mktemp -d) rm -rf $T",  # sets T for rm alone; $T expands first, empty
    "A=1 T=$(mktemp -d); rm -rf $T",
    "T=$(mktemp -d); read T; rm -rf $T",
    "T=$(mktemp -d); export T=/; rm -rf $T",
    "T=$(mktemp -d); unset T; rm -rf $T",
    "T=$(mktemp -d); for T in /; do :; done; rm -rf $T",
    'T=$(mktemp -d); eval "T=/"; rm -rf $T',
    "T=$(mktemp -d); printf -v T /; rm -rf $T",
    "T=$(mktemp -d); ssh host 'rm -rf $T'",  # assigned here, used on another host
    "T=$(mktemp -d); rm -rf $T $HOME",
    "T=$(mktemp -d); rm -rf /",
    'T=$(mktemp -d); rm -rf "$U"',
    "rm -rf $T",
    "echo $T | xargs rm -rf",
]


@pytest.mark.parametrize("template", FRESH_NO_OPINION)
def test_a_directory_made_by_mktemp_is_not_denied(template: str, tree: dict) -> None:
    """A directory made by mktemp -d in the same text is left to the normal flow."""
    command = template.format(**tree)
    assert _decide(command, tree) is None, command


@pytest.mark.parametrize("template", FRESH_STILL_DENIED)
def test_a_variable_that_is_not_provably_fresh_stays_denied(template: str, tree: dict) -> None:
    """A variable that may not hold a directory just made is still denied."""
    command = template.format(**tree)
    assert _verdict(_decide(command, tree)) == "deny", command


def test_hook_entry_lets_a_remote_mktemp_cleanup_through(tree: dict) -> None:
    """Through the real entry, a remote mktemp cleanup exits 0 with no block."""
    result = _hook("ssh host 'T=$(mktemp -d); touch $T/a; rm -rf $T'", tree)
    assert (result.returncode, result.stdout) == (0, "")


# A word before the command must not hide it. Each of these used to get no decision.
HIDDEN_COMMAND_DENIED = [
    'X="a" rm -rf /x',
    "X='a b' rm -rf /x",
    'A=1 B="2" rm -rf /x',
    "for d in a b; do rm -rf /x; done",
    "if true; then rm -rf /x; fi",
    "if x; then :; elif y; then rm -rf /x; fi",
    "if x; then :; else rm -rf /x; fi",
    "while true; do rm -rf /x; done",
    "until false; do rm -rf /x; done",
    "{{ rm -rf /x; }}",
    "true && {{ rm -rf /x; }}",
    "! rm -rf /x",
    "ssh host 'for d in a; do rm -rf /x; done'",
    "bash -c 'if x; then rm -rf /x; fi'",
]

COMPOUND_NO_OPINION = [
    "for d in a b; do echo $d; done",
    "if true; then echo hi; fi",
    'X="a" echo hi',
    "{{ echo hi; }}",
    "! true",
    "while read l; do echo $l; done",
    "for d in a; do rm /a/b; done",
    "echo do rm -rf /x",
]


@pytest.mark.parametrize("template", HIDDEN_COMMAND_DENIED)
def test_a_command_after_an_assignment_or_reserved_word_is_denied(
    template: str, tree: dict
) -> None:
    """A quoted assignment prefix, `do`, `then`, `{` or `!` does not hide a recursive force rm."""
    command = template.format(**tree)
    assert _verdict(_decide(command, tree)) == "deny", command


@pytest.mark.parametrize("template", COMPOUND_NO_OPINION)
def test_harmless_compound_commands_have_no_opinion(template: str, tree: dict) -> None:
    """Compound commands that remove nothing recursively are left to the normal flow."""
    assert _decide(template.format(**tree), tree) is None


def test_a_quoted_assignment_prefix_is_read_like_an_unquoted_one(tree: dict) -> None:
    """`X="a" rm ...` is judged exactly as `X=a rm ...` is."""
    for command in ('X="a" rm -rf {root}/tmp.abc', "X=a rm -rf {root}/tmp.abc"):
        assert _verdict(_decide(command.format(**tree), tree)) == "allow", command
