"""CLI develop dispatch module unit tests."""

import pytest
from koopa.cli_develop import _DEVELOP_HANDLERS


def test_handlers_not_empty() -> None:
    """Test that _DEVELOP_HANDLERS has entries."""
    assert len(_DEVELOP_HANDLERS) > 0


def test_handlers_all_callable() -> None:
    """Test that all handler values are callable."""
    for name, handler in _DEVELOP_HANDLERS.items():
        assert callable(handler), f"Handler for '{name}' is not callable"


def test_handlers_expected_commands() -> None:
    """Test that key develop commands are registered."""
    expected = [
        "activation-fork-audit",
        "activation-speed-test",
        "cache-functions",
        "generate-completion",
        "shellcheck",
    ]
    for cmd in expected:
        assert cmd in _DEVELOP_HANDLERS, f"Expected command '{cmd}' not in _DEVELOP_HANDLERS"


def test_activation_speed_test_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test activation-speed-test --help exits cleanly."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["activation-speed-test"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "threshold" in captured.out.lower()


def test_activation_fork_audit_help(capsys: pytest.CaptureFixture[str]) -> None:
    """Test activation-fork-audit --help exits cleanly."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["activation-fork-audit"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "fork" in captured.out.lower()


def test_activation_fork_audit_passes(capsys: pytest.CaptureFixture[str]) -> None:
    """Test that the current codebase passes the fork audit at current thresholds."""
    # This test enforces that activation-path fork counts do not regress.
    # If this test fails, a recent change added unnecessary subprocess forks
    # to the shell activation path. Check the --verbose output for culprits.
    _DEVELOP_HANDLERS["activation-fork-audit"](["--verbose"])
    captured = capsys.readouterr()
    assert "PASS" in captured.out
    assert "FAIL" not in captured.out
