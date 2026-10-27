"""Agent mode: koopa refuses commands that change the system when a coding agent runs them."""

import importlib
import sys
from pathlib import Path

import pytest
from koopa import agent_mode, cli_main
from koopa.prefix import koopa_prefix

# Keep bytecode out of the plugin tree, which ships to users.
sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(koopa_prefix()) / "plugins" / "koopa" / "hooks"))
_scan = importlib.import_module("guard_installs_scan")


@pytest.fixture
def no_agent(monkeypatch: pytest.MonkeyPatch) -> None:
    """Clear every agent marker and the override, whichever harness launched pytest."""
    for name in (*agent_mode.AGENT_MARKERS, agent_mode.AGENT_OVERRIDE):
        monkeypatch.delenv(name, raising=False)


@pytest.mark.parametrize("marker", agent_mode.AGENT_MARKERS)
def test_each_marker_turns_agent_mode_on(marker: str) -> None:
    assert agent_mode.is_agent_session({marker: "1"})


@pytest.mark.parametrize(
    ("env", "expected"),
    [
        ({}, False),
        ({"AI_AGENT": ""}, False),
        ({"CLAUDECODE": "1"}, False),
        ({"KOOPA_AGENT": "1"}, True),
        ({"KOOPA_AGENT": "0", "AI_AGENT": "pi"}, False),
        ({"KOOPA_AGENT": "", "COPILOT_CLI": "1"}, True),
    ],
)
def test_override_and_empty_values(env: dict[str, str], expected: bool) -> None:
    assert agent_mode.is_agent_session(env) is expected


@pytest.mark.parametrize(
    ("command", "remainder", "expected"),
    [
        ("install", [], True),
        ("reinstall", [], True),
        ("sync", ["default-apps"], True),
        ("uninstall", [], True),
        ("update", [], True),
        ("configure", [], True),
        ("admin", ["flush-dns"], True),
        ("admin", ["flush-dns", "--help"], False),
        ("admin", [], False),
        ("system", ["prune-apps"], True),
        ("system", ["switch-to-develop"], True),
        ("system", ["prefix"], False),
        ("system", ["info"], False),
        ("list", [], False),
        ("app", ["python"], False),
        ("develop", ["check"], False),
    ],
)
def test_is_gated(command: str, remainder: list[str], expected: bool) -> None:
    assert agent_mode.is_gated(command, remainder) is expected


def test_refusal_message_names_the_exact_command() -> None:
    message = agent_mode.refusal_message(["install", "my app"])
    assert "koopa install 'my app'" in message
    assert "own terminal" in message
    assert agent_mode.AGENT_OVERRIDE not in message


def test_hook_copies_match_agent_mode() -> None:
    """The plugin hook cannot import koopa, so it keeps copies of these lists."""
    assert _scan.KOOPA_AGENT_MARKERS == agent_mode.AGENT_MARKERS
    assert agent_mode.AGENT_OVERRIDE == _scan.KOOPA_AGENT_OVERRIDE
    assert _scan.KOOPA_GATED_COMMANDS == agent_mode.GATED_COMMANDS
    assert dict(agent_mode.GATED_SUBCOMMANDS) == _scan.KOOPA_GATED_SUBCOMMANDS


def _run_main(monkeypatch: pytest.MonkeyPatch, argv: list[str]) -> list[str]:
    """Run ``cli_main.main`` with every handler stubbed; return the handlers called."""
    called: list[str] = []
    for name in (
        "_handle_install",
        "_handle_reinstall",
        "_handle_uninstall",
        "_handle_sync",
        "_handle_update",
        "_handle_configure",
        "_handle_list",
        "_handle_system",
        "_handle_admin",
    ):
        monkeypatch.setattr(cli_main, name, lambda _args, name=name: called.append(name))
    monkeypatch.setattr(cli_main, "_prepend_koopa_bin_to_path", lambda: None)
    monkeypatch.setattr(sys, "argv", ["koopa", *argv])
    cli_main.main()
    return called


@pytest.mark.usefixtures("no_agent")
@pytest.mark.parametrize(
    "argv",
    [
        ["install", "jq"],
        ["reinstall", "jq"],
        ["sync", "default-apps"],
        ["uninstall", "jq"],
        ["update"],
        ["configure", "r"],
        ["admin", "flush-dns"],
        ["system", "prune-apps"],
    ],
)
def test_agent_refuses_commands_that_change_the_system(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str], argv: list[str]
) -> None:
    monkeypatch.setenv("AI_AGENT", "pi")
    with pytest.raises(SystemExit) as exit_info:
        _run_main(monkeypatch, argv)
    assert exit_info.value.code == 2
    assert f"koopa {' '.join(argv)}" in capsys.readouterr().err


@pytest.mark.usefixtures("no_agent")
def test_agent_never_reaches_the_handler(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("COPILOT_CLI", "1")
    called: list[str] = []
    monkeypatch.setattr(cli_main, "_handle_install", lambda _args: called.append("install"))
    monkeypatch.setattr(cli_main, "_prepend_koopa_bin_to_path", lambda: None)
    monkeypatch.setattr(sys, "argv", ["koopa", "install", "jq"])
    with pytest.raises(SystemExit):
        cli_main.main()
    assert not called


@pytest.mark.usefixtures("no_agent")
@pytest.mark.parametrize(
    ("argv", "handler"),
    [(["list"], "_handle_list"), (["system", "prefix"], "_handle_system")],
)
def test_agent_runs_read_only_commands(
    monkeypatch: pytest.MonkeyPatch, argv: list[str], handler: str
) -> None:
    monkeypatch.setenv("AI_AGENT", "pi")
    assert _run_main(monkeypatch, argv) == [handler]


@pytest.mark.usefixtures("no_agent")
def test_human_shell_runs_commands_that_change_the_system(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    assert _run_main(monkeypatch, ["install", "jq"]) == ["_handle_install"]


@pytest.mark.usefixtures("no_agent")
def test_override_lets_a_human_run_inside_a_harness(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("CLAUDE_CODE_CHILD_SESSION", "1")
    monkeypatch.setenv("KOOPA_AGENT", "0")
    assert _run_main(monkeypatch, ["update"]) == ["_handle_update"]
