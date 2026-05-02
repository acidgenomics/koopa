"""System module unit tests."""

from unittest.mock import patch

import pytest
from koopa.system import (
    arch2,
    boolean_nounset,
    color_mode,
    cpu_count,
    default_shell_name,
    major_minor_patch_version,
    major_minor_version,
    major_version,
    shell_name,
)


def test_arch2_x86_64() -> None:
    """Test arch2 maps x86_64 to amd64."""
    with patch("platform.machine", return_value="x86_64"):
        assert arch2() == "amd64"


def test_arch2_aarch64() -> None:
    """Test arch2 maps aarch64 to arm64."""
    with patch("platform.machine", return_value="aarch64"):
        assert arch2() == "arm64"


def test_arch2_arm64() -> None:
    """Test arch2 maps arm64 to arm64."""
    with patch("platform.machine", return_value="arm64"):
        assert arch2() == "arm64"


def test_arch2_i686() -> None:
    """Test arch2 maps i686 to 386."""
    with patch("platform.machine", return_value="i686"):
        assert arch2() == "386"


def test_arch2_unknown() -> None:
    """Test arch2 returns unknown arch as-is."""
    with patch("platform.machine", return_value="riscv64"):
        assert arch2() == "riscv64"


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        ("1", True),
        ("true", True),
        ("yes", True),
        ("True", True),
        ("YES", True),
        (True, True),
        (1, True),
        (42, True),
    ],
)
def test_boolean_nounset_truthy(value: str | bool | int, expected: bool) -> None:
    """Test boolean_nounset with truthy values."""
    assert boolean_nounset(value) == expected


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        ("0", False),
        ("false", False),
        ("no", False),
        ("", False),
        (None, False),
        (False, False),
        (0, False),
    ],
)
def test_boolean_nounset_falsy(
    value: str | bool | int | None,
    expected: bool,
) -> None:
    """Test boolean_nounset with falsy values."""
    assert boolean_nounset(value) == expected


def test_major_version() -> None:
    """Test major version extraction."""
    assert major_version("3.14.1") == "3"


def test_major_version_no_dot() -> None:
    """Test major version with no dots."""
    assert major_version("14") == "14"


def test_major_minor_version() -> None:
    """Test major.minor version extraction."""
    assert major_minor_version("3.14.1") == "3.14"


def test_major_minor_version_short() -> None:
    """Test major.minor version with single component."""
    assert major_minor_version("3") == "3"


def test_major_minor_patch_version() -> None:
    """Test major.minor.patch version extraction."""
    assert major_minor_patch_version("3.14.1.2") == "3.14.1"


def test_major_minor_patch_version_exact() -> None:
    """Test major.minor.patch with exactly three components."""
    assert major_minor_patch_version("1.2.3") == "1.2.3"


def test_color_mode_truecolor(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test color_mode detects truecolor."""
    monkeypatch.setenv("COLORTERM", "truecolor")
    monkeypatch.setenv("TERM", "")
    assert color_mode() == "truecolor"


def test_color_mode_256(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test color_mode detects 256 color."""
    monkeypatch.delenv("COLORTERM", raising=False)
    monkeypatch.setenv("TERM", "xterm-256color")
    assert color_mode() == "256"


def test_color_mode_basic(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test color_mode detects basic 8 color."""
    monkeypatch.delenv("COLORTERM", raising=False)
    monkeypatch.setenv("TERM", "xterm")
    assert color_mode() == "8"


def test_color_mode_none(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test color_mode returns none when unsupported."""
    monkeypatch.delenv("COLORTERM", raising=False)
    monkeypatch.setenv("TERM", "dumb")
    assert color_mode() == "none"


def test_default_shell_name(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test default_shell_name extracts shell basename."""
    monkeypatch.setenv("SHELL", "/bin/zsh")
    assert default_shell_name() == "zsh"


def test_default_shell_name_fallback(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test default_shell_name falls back to sh."""
    monkeypatch.delenv("SHELL", raising=False)
    assert default_shell_name() == "sh"


def test_shell_name_koopa_shell(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test shell_name reads KOOPA_SHELL."""
    monkeypatch.setenv("KOOPA_SHELL", "/usr/bin/bash")
    assert shell_name() == "bash"


def test_shell_name_fallback(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test shell_name delegates to default when KOOPA_SHELL unset."""
    monkeypatch.delenv("KOOPA_SHELL", raising=False)
    monkeypatch.setenv("SHELL", "/bin/zsh")
    assert shell_name() == "zsh"


def test_cpu_count_returns_positive_int() -> None:
    """Test cpu_count returns a positive integer."""
    result = cpu_count()
    assert isinstance(result, int)
    assert result >= 1
