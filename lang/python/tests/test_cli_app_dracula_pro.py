"""Tests for koopa app dracula-pro subcommands."""

import pytest
from koopa.cli_app import _PYTHON_HANDLERS


def test_dracula_pro_handlers_registered() -> None:
    """Test that both dracula-pro handlers are registered in _PYTHON_HANDLERS."""
    assert callable(_PYTHON_HANDLERS["dracula-pro-install"])
    assert callable(_PYTHON_HANDLERS["dracula-pro-check"])


def test_dracula_pro_install_help(capsys: pytest.CaptureFixture[str]) -> None:
    """--help exits cleanly and mentions --zip."""
    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS["dracula-pro-install"](["--help"])
    assert exc_info.value.code == 0
    assert "--zip" in capsys.readouterr().out


def test_dracula_pro_install_requires_zip() -> None:
    """Missing --zip exits non-zero via argparse."""
    with pytest.raises(SystemExit) as exc_info:
        _PYTHON_HANDLERS["dracula-pro-install"]([])
    assert exc_info.value.code != 0


def test_dracula_pro_install_calls_module(monkeypatch: pytest.MonkeyPatch) -> None:
    """Forwards --zip and --no-configure to koopa.dracula_pro.install."""
    calls = []
    monkeypatch.setattr(
        "koopa.dracula_pro.install",
        lambda zip_path, *, configure: calls.append((zip_path, configure)),
    )

    _PYTHON_HANDLERS["dracula-pro-install"](["--zip", "/tmp/dracula-pro-v2.2.3.zip"])
    assert calls == [("/tmp/dracula-pro-v2.2.3.zip", True)]

    calls.clear()
    _PYTHON_HANDLERS["dracula-pro-install"](
        ["--zip", "/tmp/dracula-pro-v2.2.3.zip", "--no-configure"]
    )
    assert calls == [("/tmp/dracula-pro-v2.2.3.zip", False)]


def test_dracula_pro_check_calls_module(monkeypatch: pytest.MonkeyPatch) -> None:
    """Delegates to koopa.dracula_pro.check with no arguments."""
    calls = []
    monkeypatch.setattr("koopa.dracula_pro.check", lambda: calls.append(True))

    _PYTHON_HANDLERS["dracula-pro-check"]([])
    assert calls == [True]
