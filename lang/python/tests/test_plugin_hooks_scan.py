"""Tests for the command scanner shared by the koopa plugin hooks (hooks/shell_command_scan.py).

Covers what a hook needs in order to read a command the way a shell does: a leading
`NAME=value` word, quoted or not, and a reserved word such as `do` or `{` must not hide the
command that follows; `scope` keeps one piece of shell text apart from another; and
`assignments` reports which variable a command sets and to what. The last test checks that
a hook other than the rm guard sees the commands that used to be hidden.

Safety: nothing here runs a command. Every test passes text to the scanner.
"""

import importlib
import sys
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True

_HOOKS_DIR = Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"
sys.path.insert(0, str(_HOOKS_DIR))

scan = importlib.import_module("shell_command_scan")
tmux_hook = importlib.import_module("block_tmux_kill_server")


def _heads(command: str) -> list[str]:
    """The first word of every command the scanner finds."""
    return [inv.argv[0] for inv in scan.walk(command) if inv.argv]


@pytest.mark.parametrize(
    "command",
    [
        "X=a rm -rf x",
        'X="a" rm -rf x',
        "X='a b' rm -rf x",
        "X=$(echo a) rm -rf x",
        'A=1 B="2" rm -rf x',
        'X="$(echo a)" rm -rf x',
    ],
)
def test_an_assignment_prefix_does_not_hide_the_command(command: str) -> None:
    """The command word is `rm`, whether or not the assignment value is quoted."""
    assert "rm" in _heads(command)


@pytest.mark.parametrize(
    "command",
    [
        "for d in a; do rm -rf x; done",
        "if true; then rm -rf x; fi",
        "if x; then :; elif y; then rm -rf x; fi",
        "if x; then :; else rm -rf x; fi",
        "while true; do rm -rf x; done",
        "until false; do rm -rf x; done",
        "{ rm -rf x; }",
        "true && { rm -rf x; }",
        "! rm -rf x",
        "for d in a; do X=1 rm -rf x; done",
    ],
)
def test_a_reserved_word_does_not_hide_the_command(command: str) -> None:
    """The command is the word after `do`, `then`, `else`, `elif`, `{`, `!`, and the rest."""
    assert "rm" in _heads(command)


@pytest.mark.parametrize(
    ("command", "argv"),
    [
        ('"do" rm x', ["do", "rm", "x"]),  # quoted: an ordinary word, not a reserved word
        ("echo do rm", ["echo", "do", "rm"]),  # after the command: an argument
        ("for d in a", ["for", "d", "in", "a"]),  # `for` introduces no command
    ],
)
def test_a_reserved_word_only_counts_before_the_command(command: str, argv: list) -> None:
    """Quoted, or after the command, a reserved word is left alone."""
    assert scan.walk(command)[0].argv == argv


@pytest.mark.parametrize(
    ("command", "expected"),
    [
        ("T=$(mktemp -d)", (("T", "mktemp -d"),)),
        ('T="$(mktemp -d)"', (("T", "mktemp -d"),)),
        ("T=`mktemp -d`", (("T", "mktemp -d"),)),
        ("do T=$(mktemp -d)", (("T", "mktemp -d"),)),
        ("T=$(mktemp -d) rm x", (("T", None),)),  # sets T for rm alone
        ("A=1 T=$(mktemp -d)", (("A", None), ("T", None))),
        ('T=" "', (("T", None),)),  # a space, not a substitution
        ('T="a$(mktemp -d)"', (("T", None),)),
        ("T=$(a)$(b)", (("T", None),)),
        ("T=plain", (("T", None),)),
        ("rm x", ()),
    ],
)
def test_assignments_report_a_whole_value_substitution(command: str, expected: tuple) -> None:
    """`sub` is set only for a command that is nothing but one `NAME=$(...)` assignment."""
    assert scan.walk(command)[0].assignments == expected


def test_each_piece_of_shell_text_is_its_own_scope() -> None:
    """Text given to ssh, and each `$(...)`, is a scope; its commands share one."""
    found = scan.walk("T=$(mktemp -d); ssh h 'T=1; rm -rf $T'")
    outer, mktemp, ssh, inner_assign, inner_rm = found
    assert outer.scope == ssh.scope != mktemp.scope
    assert inner_assign.scope == inner_rm.scope
    assert len({outer.scope, mktemp.scope, inner_assign.scope}) == 3


def test_scopes_follow_source_order_within_one_text() -> None:
    """Commands in one text appear in the order they were written."""
    found = scan.walk("T=$(mktemp -d); touch $T; rm -rf $T")
    in_text = [inv for inv in found if inv.scope == found[0].scope]
    assert [inv.argv[:1] for inv in in_text] == [[], ["touch"], ["rm"]]


@pytest.mark.parametrize(
    "command",
    [
        "for d in a; do tmux kill-server; done",
        'X="a" tmux kill-server',
        "{ tmux kill-server; }",
        "! tmux kill-server",
        "if true; then tmux kill-server; fi",
        "ssh host 'for d in a; do tmux kill-server; done'",
    ],
)
def test_another_hook_now_sees_a_command_that_was_hidden(command: str) -> None:
    """The tmux kill-server hook shares the scanner, so it sees these commands too."""
    assert tmux_hook.runs_tmux_kill_server(command)


def test_another_hook_still_ignores_text_that_only_mentions_the_command() -> None:
    """Reading past reserved words does not turn mentions into commands."""
    assert not tmux_hook.runs_tmux_kill_server("echo do tmux kill-server")
    assert not tmux_hook.runs_tmux_kill_server("for d in a; do echo tmux kill-server; done")
