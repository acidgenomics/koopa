"""Tests for koopa.tmux helpers."""

import os
from collections.abc import Callable
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
from koopa.tmux import reload_tmux_config, tmux_server_is_stale, warn_tmux_stale

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _run_side_effect(disk_ver: str, srv_ver: str | None) -> Callable[..., MagicMock]:
    """Return a subprocess.run side-effect for (tmux -V) and (tmux display-message).

    ``srv_ver=None`` simulates "no server running" (non-zero returncode).
    """

    def _side_effect(cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        if "-V" in cmd:
            result.stdout = f"tmux {disk_ver}\n"
            result.stderr = ""
            result.returncode = 0
        elif "display-message" in cmd:
            if srv_ver is None:
                result.stdout = ""
                result.stderr = "no server running on /tmp/tmux-0/default"
                result.returncode = 1
            else:
                result.stdout = f"{srv_ver}\n"
                result.stderr = ""
                result.returncode = 0
        else:
            result.stdout = ""
            result.stderr = ""
            result.returncode = 0
        return result

    return _side_effect


# ---------------------------------------------------------------------------
# tmux_server_is_stale
# ---------------------------------------------------------------------------


def test_stale_when_versions_differ() -> None:
    """Returns True when running server version != on-disk binary version."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("subprocess.run", side_effect=_run_side_effect("3.6b", "3.4")),
    ):
        assert tmux_server_is_stale() is True


def test_not_stale_when_versions_match() -> None:
    """Returns False when running server version == on-disk binary version."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("subprocess.run", side_effect=_run_side_effect("3.6b", "3.6b")),
    ):
        assert tmux_server_is_stale() is False


def test_not_stale_when_no_server() -> None:
    """Returns False when no tmux server is running."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("subprocess.run", side_effect=_run_side_effect("3.6b", None)),
    ):
        assert tmux_server_is_stale() is False


def test_not_stale_when_no_bundled_tmux() -> None:
    """Returns False when the bundled tmux binary is absent."""
    with patch("koopa.tmux._bundled_tmux", return_value=None):
        assert tmux_server_is_stale() is False


# ---------------------------------------------------------------------------
# reload_tmux_config
# ---------------------------------------------------------------------------


def test_reload_noop_when_no_bundled_tmux() -> None:
    """Does nothing when no bundled tmux is present."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value=None),
        patch("subprocess.run") as mock_run,
    ):
        reload_tmux_config()
        mock_run.assert_not_called()


def test_reload_noop_when_no_server(tmp_path: Path) -> None:
    """Does nothing when no tmux server is running."""
    conf = Path(os.path.join(tmp_path, "tmux.conf"))
    conf.write_text("# empty\n")
    has_session = MagicMock()
    has_session.returncode = 1  # no server
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("koopa.tmux.xdg_config_home", return_value=str(tmp_path)),
        patch("subprocess.run", return_value=has_session) as mock_run,
    ):
        reload_tmux_config()
        # Only has-session was called; source-file was not.
        mock_run.assert_called_once()
        assert "has-session" in mock_run.call_args[0][0]


def test_reload_sources_conf_when_server_running(tmp_path: Path) -> None:
    """source-file is called when a server is running and the conf exists."""
    conf_dir = Path(os.path.join(tmp_path, "tmux"))
    conf_dir.mkdir()
    conf = Path(os.path.join(conf_dir, "tmux.conf"))
    conf.write_text("# empty\n")

    def _run_side(_cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        result.returncode = 0
        return result

    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("koopa.tmux.xdg_config_home", return_value=str(tmp_path)),
        patch("subprocess.run", side_effect=_run_side) as mock_run,
    ):
        reload_tmux_config()
        calls = [c[0][0] for c in mock_run.call_args_list]
        assert any("has-session" in c for c in calls)
        assert any("source-file" in c for c in calls)


def test_reload_sets_color_mode(tmp_path: Path) -> None:
    """set-environment is called with the supplied color_mode."""
    conf_dir = Path(os.path.join(tmp_path, "tmux"))
    conf_dir.mkdir()
    Path(os.path.join(conf_dir, "tmux.conf")).write_text("# empty\n")

    def _run_side(_cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        result.returncode = 0
        return result

    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("koopa.tmux.xdg_config_home", return_value=str(tmp_path)),
        patch("subprocess.run", side_effect=_run_side) as mock_run,
    ):
        reload_tmux_config("light")
        calls = [c[0][0] for c in mock_run.call_args_list]
        env_call = next(c for c in calls if "set-environment" in c)
        assert "KOOPA_COLOR_MODE" in env_call
        assert "light" in env_call


# ---------------------------------------------------------------------------
# warn_tmux_stale
# ---------------------------------------------------------------------------


def test_warn_stale_emits_warning(capsys: pytest.CaptureFixture[str]) -> None:
    """warn() is called with kill-server guidance when server is stale."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("subprocess.run", side_effect=_run_side_effect("3.6b", "3.4")),
    ):
        result = warn_tmux_stale()
    assert result is False
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Warning" in combined
    assert "kill-server" in combined


def test_warn_not_stale_no_output(capsys: pytest.CaptureFixture[str]) -> None:
    """No warning is emitted when the server is current."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("subprocess.run", side_effect=_run_side_effect("3.6b", "3.6b")),
    ):
        result = warn_tmux_stale()
    assert result is True
    captured = capsys.readouterr()
    assert "Warning" not in (captured.err + captured.out)


def test_warn_no_server_no_output(capsys: pytest.CaptureFixture[str]) -> None:
    """No warning when no server is running."""
    with (
        patch("koopa.tmux._bundled_tmux", return_value="/fake/bin/tmux"),
        patch("subprocess.run", side_effect=_run_side_effect("3.6b", None)),
    ):
        result = warn_tmux_stale()
    assert result is True
    captured = capsys.readouterr()
    assert "Warning" not in (captured.err + captured.out)
