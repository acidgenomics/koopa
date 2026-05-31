"""Alert module unit tests."""

import pytest
from koopa.alert import _supports_color, ansi_escape


def test_supports_color_no_color_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test _supports_color returns False when NO_COLOR is set."""
    monkeypatch.setenv("NO_COLOR", "1")
    assert _supports_color() is False


def test_supports_color_xterm(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test _supports_color returns True for xterm."""
    monkeypatch.delenv("NO_COLOR", raising=False)
    monkeypatch.setenv("TERM", "xterm")
    monkeypatch.delenv("COLORTERM", raising=False)
    assert _supports_color() is True


def test_supports_color_colorterm(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test _supports_color returns True when COLORTERM is set."""
    monkeypatch.delenv("NO_COLOR", raising=False)
    monkeypatch.setenv("TERM", "")
    monkeypatch.setenv("COLORTERM", "truecolor")
    assert _supports_color() is True


def test_supports_color_dumb_term(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test _supports_color returns False for dumb terminal."""
    monkeypatch.delenv("NO_COLOR", raising=False)
    monkeypatch.setenv("TERM", "dumb")
    monkeypatch.delenv("COLORTERM", raising=False)
    assert _supports_color() is False


def test_ansi_escape_with_color(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test ansi_escape returns escape sequence when color supported."""
    monkeypatch.delenv("NO_COLOR", raising=False)
    monkeypatch.setenv("COLORTERM", "truecolor")
    result = ansi_escape("31")
    assert result == "\033[31m"


def test_ansi_escape_no_color(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test ansi_escape returns empty string when NO_COLOR set."""
    monkeypatch.setenv("NO_COLOR", "1")
    assert ansi_escape("31") == ""
