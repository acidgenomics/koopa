"""CLI develop dispatch module unit tests."""

from pathlib import Path

import pytest
from koopa.cli_develop import _DEVELOP_HANDLERS, _detect_color_mode_thrash


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
        "color-mode-audit",
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


# ---------------------------------------------------------------------------
# _detect_color_mode_thrash unit tests
# ---------------------------------------------------------------------------


def test_detect_color_mode_thrash_healthy() -> None:
    """A log with one genuine toggle and stabilization is not thrash."""
    lines = [
        "▸ Applying color mode: dark\n",
        "** Color mode already applied: dark\n",
        "** Color mode already applied: dark\n",
        "▸ Applying color mode: light\n",  # legitimate user toggle
        "** Color mode already applied: light\n",
        "** Color mode already applied: light\n",
    ]
    longest, _ = _detect_color_mode_thrash(lines)
    assert longest < 4


def test_detect_color_mode_thrash_detected() -> None:
    """Four consecutive alternating applies with no stabilization is thrash."""
    lines = [
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
    ]
    longest, run = _detect_color_mode_thrash(lines)
    assert longest >= 4
    modes = [m for m, _ in run]
    # Verify the run strictly alternates.
    for i in range(1, len(modes)):
        assert modes[i] != modes[i - 1], "run should strictly alternate"


def test_detect_color_mode_thrash_stabilization_resets_run() -> None:
    """An 'already applied' line between applies resets the run counter."""
    lines = [
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "** Color mode already applied: dark\n",  # stabilization — reset
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
    ]
    longest, _ = _detect_color_mode_thrash(lines)
    # The first burst is length 3, reset, then another 2 — no burst reaches 4.
    assert longest < 4


def test_detect_color_mode_thrash_tolerates_prefixes() -> None:
    """Lines with ▸/** alert prefixes and plain lines both parse correctly."""
    lines_with_prefix = [
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
    ]
    lines_plain = [
        "Applying color mode: dark\n",
        "Applying color mode: light\n",
        "Applying color mode: dark\n",
        "Applying color mode: light\n",
    ]
    longest_prefix, _ = _detect_color_mode_thrash(lines_with_prefix)
    longest_plain, _ = _detect_color_mode_thrash(lines_plain)
    assert longest_prefix == 4
    assert longest_plain == 4


def test_detect_color_mode_thrash_parses_timestamps() -> None:
    """ISO-8601 timestamps are captured and detection still triggers."""
    lines = [
        "[2026-06-06T19:46:47-04:00] Applying color mode: light\n",
        "[2026-06-06T19:46:48-04:00] Applying color mode: dark\n",
        "[2026-06-06T19:46:49-04:00] Applying color mode: light\n",
        "[2026-06-06T19:46:50-04:00] Applying color mode: dark\n",
    ]
    longest, run = _detect_color_mode_thrash(lines)
    assert longest >= 4
    # Timestamps should be captured.
    timestamps = [ts for _, ts in run]
    assert all(ts is not None for ts in timestamps)
    assert timestamps[0] == "2026-06-06T19:46:47-04:00"
    assert timestamps[-1] == "2026-06-06T19:46:50-04:00"


def test_detect_color_mode_thrash_untimestamped_returns_none_ts() -> None:
    """Lines without timestamps return None for the timestamp field."""
    lines = [
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
        "▸ Applying color mode: dark\n",
        "▸ Applying color mode: light\n",
    ]
    longest, run = _detect_color_mode_thrash(lines)
    assert longest >= 4
    assert all(ts is None for _, ts in run)


def test_detect_color_mode_thrash_empty_log() -> None:
    """An empty log returns zero length and empty run."""
    longest, run = _detect_color_mode_thrash([])
    assert longest == 0
    assert run == []


# ---------------------------------------------------------------------------
# _handle_color_mode_audit integration tests (via temp log files)
# ---------------------------------------------------------------------------


def test_color_mode_audit_help(capsys: pytest.CaptureFixture[str]) -> None:
    """--help exits cleanly with usage info."""
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["color-mode-audit"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "thrash" in captured.out.lower()


def test_color_mode_audit_passes_on_clean_log(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A log with no thrash produces PASS and exit 0."""
    log = tmp_path / "color-mode-sync.log"
    log.write_text(
        "▸ Applying color mode: dark\n"
        "** Color mode already applied: dark\n"
        "** Color mode already applied: dark\n"
        "▸ Applying color mode: light\n"
        "** Color mode already applied: light\n"
    )
    _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(log)])
    captured = capsys.readouterr()
    assert "PASS" in captured.out
    assert "FAIL" not in captured.out


def test_color_mode_audit_fails_on_thrash_log(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A log with thrash produces FAIL and exit 1."""
    log = tmp_path / "color-mode-sync.log"
    log.write_text(
        "▸ Applying color mode: light\n"
        "▸ Applying color mode: dark\n"
        "▸ Applying color mode: light\n"
        "▸ Applying color mode: dark\n"
    )
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(log)])
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "FAIL" in captured.out


def test_color_mode_audit_verbose_on_thrash(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """--verbose reports the mode sequence on a thrashing log."""
    log = tmp_path / "color-mode-sync.log"
    log.write_text(
        "[2026-06-06T19:46:47-04:00] Applying color mode: light\n"
        "[2026-06-06T19:46:48-04:00] Applying color mode: dark\n"
        "[2026-06-06T19:46:49-04:00] Applying color mode: light\n"
        "[2026-06-06T19:46:50-04:00] Applying color mode: dark\n"
    )
    with pytest.raises(SystemExit) as exc_info:
        _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(log), "--verbose"])
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "FAIL" in captured.out
    assert "light" in captured.out
    assert "dark" in captured.out
    assert "2026-06-06T19:46:47" in captured.out


def test_color_mode_audit_missing_log_is_pass(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A missing --log path produces PASS (no log = nothing to complain about)."""
    _DEVELOP_HANDLERS["color-mode-audit"](["--log", str(tmp_path / "nonexistent.log")])
    captured = capsys.readouterr()
    assert "PASS" in captured.out
