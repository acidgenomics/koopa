"""CLI bin dispatch module unit tests."""

from koopa.cli_bin import _HANDLERS


def test_handlers_not_empty() -> None:
    """Test that _HANDLERS has entries."""
    assert len(_HANDLERS) > 0


def test_handlers_all_callable() -> None:
    """Test that all handler values are callable."""
    for name, handler in _HANDLERS.items():
        assert callable(handler), f"Handler for '{name}' is not callable"


def test_handlers_expected_commands() -> None:
    """Test that key utility commands are registered."""
    expected = [
        "rename-snake-case",
        "rename-kebab-case",
        "clone",
        "download",
        "extract",
        "find-and-replace",
        "sort-lines",
        "ip-address",
    ]
    for cmd in expected:
        assert cmd in _HANDLERS, f"Expected command '{cmd}' not in _HANDLERS"


def test_jekyll_serve_not_in_handlers() -> None:
    """Test that jekyll-serve is not in _HANDLERS (use koopa app jekyll serve)."""
    assert "jekyll-serve" not in _HANDLERS


def test_handler_rename_snake_case_help(capsys) -> None:
    """Test rename-snake-case --help exits cleanly."""
    import pytest

    with pytest.raises(SystemExit) as exc_info:
        _HANDLERS["rename-snake-case"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "snake_case" in captured.out.lower() or "snake" in captured.out.lower()


def test_handler_download_help(capsys) -> None:
    """Test download --help exits cleanly."""
    import pytest

    with pytest.raises(SystemExit) as exc_info:
        _HANDLERS["download"](["--help"])
    assert exc_info.value.code == 0
    captured = capsys.readouterr()
    assert "url" in captured.out.lower()
