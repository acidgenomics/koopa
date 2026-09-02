"""Tests for koopa.progress build-log-tail formatting."""

import koopa.progress as progress_mod
import pytest
from koopa.progress import _cap_line_width, _format_log_tail_text


def test_format_log_tail_text_empty_lines() -> None:
    """An empty log still reports the failure, without crashing on an empty list."""
    assert _format_log_tail_text([]) == "  Build failed.\n"


def test_format_log_tail_text_omits_error_block_when_tail_covers_it() -> None:
    """No 'Error lines' block is printed when the tail already holds every error line."""
    lines = ["Looking in indexes: https://example.test\n", "ERROR: something broke\n"]
    out = _format_log_tail_text(lines)
    assert "ERROR: something broke" in out
    assert "Error lines" not in out


def test_format_log_tail_text_keeps_error_block_when_tail_cuts_it_off(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The 'Error lines' block is kept when the tail is too short to cover an error line."""
    monkeypatch.setattr(progress_mod, "_LOG_TAIL_LINES", 1)
    lines = ["ERROR: first failure\n", "a later, unrelated line\n"]
    out = progress_mod._format_log_tail_text(lines)
    assert "Error lines (1):" in out
    assert "ERROR: first failure" in out


def test_cap_line_width_truncates_long_line() -> None:
    """A line far past the width budget is cut and marked with an ellipsis."""
    long_line = "x" * 4000 + "\n"
    capped = _cap_line_width(long_line, 500)
    assert capped.endswith("…\n")
    assert len(capped) < len(long_line)


def test_cap_line_width_leaves_short_line_untouched() -> None:
    """A line already within the width budget is returned unchanged."""
    short_line = "a short pip error\n"
    assert _cap_line_width(short_line, 500) == short_line
