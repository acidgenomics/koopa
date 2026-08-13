"""System module unit tests."""

import base64
import gzip
import json
import os
import subprocess
import zlib
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
from koopa.check import check_system
from koopa.system import (
    arch2,
    color_mode,
    cpu_count,
    major_minor_patch_version,
    major_minor_version,
    major_version,
    os_appearance_mode,
    revert_direnv_env,
    safe_build_env,
)


def _direnv_diff(prev: dict, new: dict, *, compress: str = "zlib") -> str:
    """Build a 'DIRENV_DIFF'-shaped payload matching direnv 2.37's own encoding.

    direnv itself uses zlib; 'gzip' exercises '_decode_direnv_diff()'s fallback
    branch for the same wire format under a different compressor.
    """
    raw = json.dumps({"p": prev, "n": new}).encode()
    payload = gzip.compress(raw) if compress == "gzip" else zlib.compress(raw)
    return base64.urlsafe_b64encode(payload).decode().rstrip("=")


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


def test_safe_build_env_drops_unlisted_project_var(monkeypatch: pytest.MonkeyPatch) -> None:
    """A project-scoped var (e.g. direnv-loaded) never reaches a build subprocess."""
    monkeypatch.setenv("SOME_PROJECT_API_KEY", "fake-value")
    assert "SOME_PROJECT_API_KEY" not in safe_build_env()


def test_safe_build_env_regression_leaked_dsn_excluded(monkeypatch: pytest.MonkeyPatch) -> None:
    """Regression: the exact var name that previously leaked stays excluded."""
    monkeypatch.setenv("MYPROJECT_SENTRY_DSN", "https://fake@example.com/1")
    assert "MYPROJECT_SENTRY_DSN" not in safe_build_env()


def test_safe_build_env_keeps_exact_name(monkeypatch: pytest.MonkeyPatch) -> None:
    """A generic build-toolchain var on the exact-name allowlist passes through."""
    monkeypatch.setenv("CC", "clang")
    assert safe_build_env()["CC"] == "clang"


def test_safe_build_env_keeps_namespaced_prefix(monkeypatch: pytest.MonkeyPatch) -> None:
    """A var under a tool-owned prefix (e.g. koopa's own) passes through."""
    monkeypatch.setenv("KOOPA_INSTALL_JOBS", "8")
    assert safe_build_env()["KOOPA_INSTALL_JOBS"] == "8"


def test_revert_direnv_env_removes_added_var(monkeypatch: pytest.MonkeyPatch) -> None:
    """A var direnv added (absent from 'p') is removed entirely."""
    monkeypatch.setenv("DIRENV_DIFF", _direnv_diff({}, {"PROJECT_API_KEY": "fake-value"}))
    monkeypatch.setenv("PROJECT_API_KEY", "fake-value")

    reverted = revert_direnv_env()

    assert "PROJECT_API_KEY" not in os.environ
    assert "PROJECT_API_KEY" in reverted


def test_revert_direnv_env_restores_changed_var(monkeypatch: pytest.MonkeyPatch) -> None:
    """A var direnv changed (present in both 'p' and 'n') is restored to 'p'."""
    monkeypatch.setenv(
        "DIRENV_DIFF",
        _direnv_diff({"PATH": "/usr/bin:/bin"}, {"PATH": "/project/venv/bin:/usr/bin:/bin"}),
    )
    monkeypatch.setenv("PATH", "/project/venv/bin:/usr/bin:/bin")

    reverted = revert_direnv_env()

    assert os.environ["PATH"] == "/usr/bin:/bin"
    assert "PATH" in reverted


def test_revert_direnv_env_decodes_gzip_payload(monkeypatch: pytest.MonkeyPatch) -> None:
    """'_decode_direnv_diff()'s gzip fallback (non-zlib payload) also decodes."""
    monkeypatch.setenv(
        "DIRENV_DIFF",
        _direnv_diff({}, {"PROJECT_API_KEY": "fake-value"}, compress="gzip"),
    )
    monkeypatch.setenv("PROJECT_API_KEY", "fake-value")

    reverted = revert_direnv_env()

    assert "PROJECT_API_KEY" not in os.environ
    assert "PROJECT_API_KEY" in reverted


def test_revert_direnv_env_noop_when_unset(monkeypatch: pytest.MonkeyPatch) -> None:
    """No-op, no raise, when direnv isn't active."""
    monkeypatch.delenv("DIRENV_DIFF", raising=False)
    assert revert_direnv_env() == []


def test_revert_direnv_env_noop_on_garbage_payload(monkeypatch: pytest.MonkeyPatch) -> None:
    """No-op, no raise, on a malformed 'DIRENV_DIFF' -- never a partial apply."""
    monkeypatch.setenv("DIRENV_DIFF", "not-valid-base64!!!")
    assert revert_direnv_env() == []


def test_revert_direnv_env_is_idempotent(monkeypatch: pytest.MonkeyPatch) -> None:
    """A second call is a no-op.

    'DIRENV_DIFF' is left in 'os.environ' by the first call, but every diffed
    key already matches its pre-'.envrc' value by then, so a second call
    (e.g. after an os.execv restart) finds nothing left to change -- this is
    what stops a duplicate message on a restart.
    """
    monkeypatch.setenv("DIRENV_DIFF", _direnv_diff({}, {"PROJECT_TOKEN": "fake"}))
    monkeypatch.setenv("PROJECT_TOKEN", "fake")

    first = revert_direnv_env()
    second = revert_direnv_env()

    assert first == ["PROJECT_TOKEN"]
    assert second == []


def test_check_system_skips_macos_icloud_drive(monkeypatch: pytest.MonkeyPatch) -> None:
    """`koopa system check` must not run the macOS iCloud Drive sync check."""
    monkeypatch.setattr("koopa.system.is_macos", lambda: True)
    monkeypatch.setattr("koopa.system.is_debian_like", lambda: False)
    monkeypatch.setattr("koopa.check.check_build_system", lambda: None)
    monkeypatch.setattr("koopa.check.check_bootstrap_version", lambda: True)
    monkeypatch.setattr("koopa.check.check_installed_apps", lambda: True)
    monkeypatch.setattr("koopa.check.check_broken_app_installs", lambda: True)
    monkeypatch.setattr("koopa.check.check_broken_symlinks", lambda: True)
    monkeypatch.setattr("koopa.check.check_missing_default_apps", lambda: True)
    monkeypatch.setattr("koopa.check.check_disk", lambda path: True)
    monkeypatch.setattr("koopa.check.check_tmux_server_stale", lambda: True)
    monkeypatch.setattr("koopa.check.check_macos_system_python", lambda: True)
    monkeypatch.setattr("koopa.check.check_macos_xcode_clt", lambda: True)
    monkeypatch.setattr(
        "koopa.check.check_macos_icloud_drive",
        lambda: (_ for _ in ()).throw(
            AssertionError("iCloud check should not run during koopa system check")
        ),
    )
    assert check_system() is True


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
