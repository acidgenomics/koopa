"""System module unit tests."""

import subprocess
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
from koopa.system import (
    arch2,
    color_mode,
    cpu_count,
    major_minor_patch_version,
    major_minor_version,
    major_version,
    os_appearance_mode,
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


def test_cpu_count_returns_positive_int() -> None:
    """Test cpu_count returns a positive integer."""
    result = cpu_count()
    assert isinstance(result, int)
    assert result >= 1


# os_appearance_mode — Linux headless cache-file fallback


def _write_color_cache(tmp_path: Path, value: str) -> None:
    cache_dir = tmp_path / ".cache" / "koopa"
    cache_dir.mkdir(parents=True)
    (cache_dir / "color-mode").write_text(value + "\n")


def _clear_graphical_session_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Strip every signal `_linux_has_graphical_session` treats as positive."""
    monkeypatch.delenv("DISPLAY", raising=False)
    monkeypatch.delenv("WAYLAND_DISPLAY", raising=False)
    monkeypatch.delenv("XDG_CURRENT_DESKTOP", raising=False)
    monkeypatch.setenv("XDG_SESSION_TYPE", "tty")


def _set_graphical_session_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Mark the environment as a real desktop session (Wayland)."""
    monkeypatch.delenv("DISPLAY", raising=False)
    monkeypatch.setenv("WAYLAND_DISPLAY", "wayland-0")
    monkeypatch.delenv("XDG_CURRENT_DESKTOP", raising=False)
    monkeypatch.setenv("XDG_SESSION_TYPE", "wayland")


def test_os_appearance_mode_linux_cache_light(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """On headless Linux (no gdbus/gsettings), cache file 'light' → 'light'."""
    _write_color_cache(tmp_path, "light")
    monkeypatch.setenv("HOME", str(tmp_path))
    _clear_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", return_value=None),
    ):
        assert os_appearance_mode() == "light"


def test_os_appearance_mode_linux_cache_dark(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """On headless Linux (no gdbus/gsettings), cache file 'dark' → 'dark'."""
    _write_color_cache(tmp_path, "dark")
    monkeypatch.setenv("HOME", str(tmp_path))
    _clear_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", return_value=None),
    ):
        assert os_appearance_mode() == "dark"


def test_os_appearance_mode_linux_no_cache(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """On headless Linux with no cache file, default 'dark' is preserved."""
    monkeypatch.setenv("HOME", str(tmp_path))
    _clear_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", return_value=None),
    ):
        assert os_appearance_mode() == "dark"


def test_os_appearance_mode_linux_headless_skips_portal_probe(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Headless session skips the gdbus/gsettings probes entirely.

    On a headless session (tty, no DISPLAY/WAYLAND_DISPLAY/desktop), the
    gdbus/gsettings probes are never invoked -- only the cache file is read.
    Regression test for the ~28s D-Bus activation timeout hit on SLURM login
    nodes: the session bus is present there, so a naive "is gdbus on PATH"
    check would still shell out and block. Gating on session type is what
    avoids the subprocess call entirely.
    """
    _write_color_cache(tmp_path, "light")
    monkeypatch.setenv("HOME", str(tmp_path))
    _clear_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", side_effect=_which_gdbus_only) as which_mock,
        patch("subprocess.run") as run_mock,
    ):
        assert os_appearance_mode() == "light"
        run_mock.assert_not_called()
        which_mock.assert_not_called()


def test_os_appearance_mode_linux_portal_timeout_falls_back(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A gdbus call that hangs past the subprocess timeout falls back.

    Falls through to the cache file rather than propagating
    ``TimeoutExpired``.
    """
    _write_color_cache(tmp_path, "dark")
    monkeypatch.setenv("HOME", str(tmp_path))
    _set_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", side_effect=_which_gdbus_only),
        patch(
            "subprocess.run",
            side_effect=subprocess.TimeoutExpired(cmd="gdbus", timeout=5),
        ),
    ):
        assert os_appearance_mode() == "dark"


# os_appearance_mode — Linux XDG portal (gdbus) parsing
#
# gdbus prints the variant-wrapped value, e.g. '(<<uint32 1>>,)'. The type
# name 'uint32' contains a literal '2', so a naive '"2" in stdout' substring
# check always matches regardless of the actual value.


def _which_gdbus_only(name: str) -> str | None:
    return "/usr/bin/gdbus" if name == "gdbus" else None


def test_os_appearance_mode_linux_portal_prefer_dark(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Portal color-scheme 1 (prefer-dark) resolves to 'dark'.

    Regression test: 'uint32' contains a '2', so a substring check against
    the raw stdout would previously misclassify this as 'light'.
    """
    monkeypatch.delenv("HOME", raising=False)
    _set_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", side_effect=_which_gdbus_only),
        patch(
            "subprocess.run",
            return_value=MagicMock(returncode=0, stdout="(<<uint32 1>>,)\n"),
        ),
    ):
        assert os_appearance_mode() == "dark"


def test_os_appearance_mode_linux_portal_prefer_light(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Portal color-scheme 2 (prefer-light) resolves to 'light'."""
    monkeypatch.delenv("HOME", raising=False)
    _set_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", side_effect=_which_gdbus_only),
        patch(
            "subprocess.run",
            return_value=MagicMock(returncode=0, stdout="(<<uint32 2>>,)\n"),
        ),
    ):
        assert os_appearance_mode() == "light"


def test_os_appearance_mode_linux_portal_no_preference_falls_back(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Portal color-scheme 0 (no-preference) falls through to the cache file."""
    _write_color_cache(tmp_path, "light")
    monkeypatch.setenv("HOME", str(tmp_path))
    _set_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", side_effect=_which_gdbus_only),
        patch(
            "subprocess.run",
            return_value=MagicMock(returncode=0, stdout="(<<uint32 0>>,)\n"),
        ),
    ):
        assert os_appearance_mode() == "light"


def test_os_appearance_mode_linux_portal_unavailable_falls_back(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A non-zero gdbus exit (portal absent) falls through to the cache file."""
    _write_color_cache(tmp_path, "dark")
    monkeypatch.setenv("HOME", str(tmp_path))
    _set_graphical_session_env(monkeypatch)
    with (
        patch("platform.system", return_value="Linux"),
        patch("shutil.which", side_effect=_which_gdbus_only),
        patch("subprocess.run", return_value=MagicMock(returncode=1, stdout="")),
    ):
        assert os_appearance_mode() == "dark"
