"""Tests for koopa.brew helpers — non-interactive invariants."""

import subprocess
import sys
from collections.abc import Callable
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _empty_run_side_effect() -> Callable[..., MagicMock]:
    """Return a subprocess.run side-effect that yields empty stdout for all calls."""

    def _side_effect(_cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        result.stdout = ""
        result.stderr = ""
        result.returncode = 0
        return result

    return _side_effect


# ---------------------------------------------------------------------------
# Unit tests for _brew_env
# ---------------------------------------------------------------------------


def test_brew_env_sets_noninteractive() -> None:
    """_brew_env must set NONINTERACTIVE and HOMEBREW_NO_ENV_HINTS."""
    from koopa.brew import _brew_env

    env = _brew_env()
    assert env["NONINTERACTIVE"] == "1"
    assert env["HOMEBREW_NO_ENV_HINTS"] == "1"
    assert env["HOMEBREW_NO_AUTO_UPDATE"] == "1"


def test_brew_env_is_a_copy() -> None:
    """_brew_env must not mutate os.environ."""
    import os

    from koopa.brew import _brew_env

    before = os.environ.get("NONINTERACTIVE")
    _brew_env()
    assert os.environ.get("NONINTERACTIVE") == before


def test_brew_env_sets_curlrc() -> None:
    """_brew_env must point HOMEBREW_CURLRC at an existing absolute path.

    An absolute path is required: HOMEBREW_CURLRC's own semantics only pass
    ``--disable`` (which suppresses the user's ~/.curlrc) when the value
    starts with '/'. A relative value would fall back to loading ~/.curlrc.
    """
    import os

    from koopa.brew import _brew_env

    env = _brew_env()
    curlrc = env["HOMEBREW_CURLRC"]
    assert os.path.isabs(curlrc)
    assert os.path.isfile(curlrc)


def test_brew_curlrc_fallback_content() -> None:
    """The fallback curlrc must set a stall guard, not just a retry count."""
    from koopa.brew import _brew_curlrc_fallback

    with open(_brew_curlrc_fallback(), encoding="utf-8") as f:
        content = f.read()
    assert "connect-timeout" in content
    assert "speed-limit" in content
    assert "speed-time" in content


def test_brew_env_respects_user_curlrc() -> None:
    """_brew_env must not override a HOMEBREW_CURLRC the caller already set."""
    from koopa.brew import _brew_env

    with patch.dict("os.environ", {"HOMEBREW_CURLRC": "/custom/path"}):
        env = _brew_env()
    assert env["HOMEBREW_CURLRC"] == "/custom/path"


def test_brew_env_prefers_user_curlrc_when_present() -> None:
    """_brew_env must reuse the user's own curlrc rather than generating one.

    koopa's own dotfiles ship the stall guard directly in ~/.curlrc (see
    opt/dotfiles/chezmoi/dot_curlrc.tmpl), so Homebrew should read that file
    instead of a separate koopa-generated copy.
    """
    from koopa.brew import _brew_env

    with (
        patch("koopa.brew._user_curlrc_path", return_value="/home/user/.curlrc"),
        patch("koopa.brew._brew_curlrc_fallback") as mock_fallback,
    ):
        env = _brew_env()

    assert env["HOMEBREW_CURLRC"] == "/home/user/.curlrc"
    mock_fallback.assert_not_called()


def test_brew_env_falls_back_when_no_user_curlrc() -> None:
    """_brew_env must generate a minimal stall guard when the user has no curlrc."""
    import os

    from koopa.brew import _brew_env

    with patch("koopa.brew._user_curlrc_path", return_value=None):
        env = _brew_env()

    curlrc = env["HOMEBREW_CURLRC"]
    assert os.path.isabs(curlrc)
    assert os.path.isfile(curlrc)
    with open(curlrc, encoding="utf-8") as f:
        content = f.read()
    assert "connect-timeout" in content
    assert "speed-limit" in content
    assert "speed-time" in content


# ---------------------------------------------------------------------------
# Unit tests for _user_curlrc_path: locating the user's own curl config
# ---------------------------------------------------------------------------


def test_user_curlrc_path_prefers_curl_home(tmp_path: Path) -> None:
    """CURL_HOME/.curlrc must win over XDG_CONFIG_HOME/curlrc and ~/.curlrc."""
    from koopa.brew import _user_curlrc_path

    curl_home = tmp_path / "curl_home"
    curl_home.mkdir()
    (curl_home / ".curlrc").write_text("# curl_home\n")
    xdg_config = tmp_path / "xdg_config"
    xdg_config.mkdir()
    (xdg_config / "curlrc").write_text("# xdg\n")
    home = tmp_path / "home"
    home.mkdir()
    (home / ".curlrc").write_text("# home\n")

    with patch.dict(
        "os.environ",
        {"CURL_HOME": str(curl_home), "XDG_CONFIG_HOME": str(xdg_config), "HOME": str(home)},
        clear=True,
    ):
        assert _user_curlrc_path() == str(curl_home / ".curlrc")


def test_user_curlrc_path_falls_back_to_xdg_config_home(tmp_path: Path) -> None:
    """<xdg_config_home>/curlrc must win over ~/.curlrc when CURL_HOME is unset."""
    from koopa.brew import _user_curlrc_path

    xdg_config = tmp_path / "xdg_config"
    xdg_config.mkdir()
    (xdg_config / "curlrc").write_text("# xdg\n")
    home = tmp_path / "home"
    home.mkdir()
    (home / ".curlrc").write_text("# home\n")

    with patch.dict(
        "os.environ", {"XDG_CONFIG_HOME": str(xdg_config), "HOME": str(home)}, clear=True
    ):
        assert _user_curlrc_path() == str(xdg_config / "curlrc")


def test_user_curlrc_path_falls_back_to_home_curlrc(tmp_path: Path) -> None:
    """~/.curlrc must be used when neither CURL_HOME nor XDG_CONFIG_HOME/curlrc exist."""
    from koopa.brew import _user_curlrc_path

    xdg_config = tmp_path / "xdg_config"
    xdg_config.mkdir()
    home = tmp_path / "home"
    home.mkdir()
    (home / ".curlrc").write_text("# home\n")

    with patch.dict(
        "os.environ", {"XDG_CONFIG_HOME": str(xdg_config), "HOME": str(home)}, clear=True
    ):
        assert _user_curlrc_path() == str(home / ".curlrc")


def test_user_curlrc_path_returns_none_when_nothing_exists(tmp_path: Path) -> None:
    """No curl config anywhere must yield None, not raise."""
    from koopa.brew import _user_curlrc_path

    home = tmp_path / "home"
    home.mkdir()

    with patch.dict("os.environ", {"HOME": str(home)}, clear=True):
        assert _user_curlrc_path() is None


# ---------------------------------------------------------------------------
# Unit tests for _brew helper
# ---------------------------------------------------------------------------


def test_brew_helper_starves_stdin_and_sets_env() -> None:
    """_brew must pass stdin=DEVNULL and NONINTERACTIVE env to subprocess.run."""
    with patch("koopa.brew.subprocess.run") as mock_run:
        mock_run.return_value = MagicMock(stdout="", stderr="", returncode=0)
        from koopa.brew import _brew

        _brew("update", capture=False)

    mock_run.assert_called_once()
    _, kwargs = mock_run.call_args
    assert kwargs.get("stdin") is subprocess.DEVNULL, "stdin must be DEVNULL"
    assert kwargs["env"]["NONINTERACTIVE"] == "1"


# ---------------------------------------------------------------------------
# Regression lock: every brew call in _update_homebrew is non-interactive
# ---------------------------------------------------------------------------


def test_update_homebrew_all_brew_calls_noninteractive() -> None:
    """Every brew subprocess spawned by _update_homebrew must be non-interactive.

    A future edit that introduces a raw ``subprocess.run(["brew", ...])`` without
    ``stdin=DEVNULL`` and ``NONINTERACTIVE`` will break this test, preventing the
    39-hour hang from returning.
    """
    with (
        patch("koopa.brew.subprocess.run", side_effect=_empty_run_side_effect()) as mock_run,
        patch("koopa.brew.brew_prefix", return_value="/opt/homebrew"),
        patch("koopa.system.has_sudo", return_value=True),
        patch("koopa.installers.homebrew.is_macos", return_value=False),
    ):
        from koopa.installers.homebrew import _update_homebrew

        _update_homebrew()

    brew_calls = [c for c in mock_run.call_args_list if c.args[0][0] == "brew"]
    assert brew_calls, "Expected at least one brew subprocess call"

    for c in brew_calls:
        kwargs = c.kwargs
        cmd_str = " ".join(c.args[0])
        assert kwargs.get("stdin") is subprocess.DEVNULL, (
            f"brew call missing stdin=DEVNULL: {cmd_str}"
        )
        assert kwargs.get("env", {}).get("NONINTERACTIVE") == "1", (
            f"brew call missing NONINTERACTIVE env: {cmd_str}"
        )


# ---------------------------------------------------------------------------
# brew_upgrade_casks: the most likely hang point (pkg casks shell out to sudo)
# ---------------------------------------------------------------------------


def test_brew_upgrade_casks_reinstall_is_noninteractive() -> None:
    """Brew reinstall --cask must be non-interactive when casks are outdated."""

    def _side_effect(cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        # Return one outdated cask for the --greedy query.
        if "outdated" in cmd and "--cask" in cmd:
            result.stdout = "firefox (128.0 < 129.0)\n"
        else:
            result.stdout = ""
        result.stderr = ""
        result.returncode = 0
        return result

    with (
        patch("koopa.brew.subprocess.run", side_effect=_side_effect) as mock_run,
        patch("koopa.system.has_sudo", return_value=True),
    ):
        from koopa.brew import brew_upgrade_casks

        brew_upgrade_casks()

    reinstall_calls = [
        c for c in mock_run.call_args_list if "reinstall" in c.args[0] and "--cask" in c.args[0]
    ]
    assert reinstall_calls, "Expected a brew reinstall --cask call"
    for c in reinstall_calls:
        kwargs = c.kwargs
        assert kwargs.get("stdin") is subprocess.DEVNULL
        assert kwargs.get("env", {}).get("NONINTERACTIVE") == "1"


def test_brew_upgrade_casks_skips_versionless_casks_with_same_version() -> None:
    """Casks with a versionless install should not be force-reinstalled repeatedly."""

    def _side_effect(cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        if "outdated" in cmd and "--cask" in cmd and "--json=v2" in cmd:
            result.stdout = (
                '{"formulae":[],"casks":[{"name":"font-fira-mono",'
                '"installed_versions":["latest"],"current_version":"latest",'
                '"pinned":false,"pinned_version":null}]}'
            )
        else:
            result.stdout = "font-fira-mono\n"
        result.stderr = ""
        result.returncode = 0
        return result

    with (
        patch("koopa.brew.subprocess.run", side_effect=_side_effect) as mock_run,
        patch("koopa.system.has_sudo", return_value=True),
    ):
        from koopa.brew import brew_upgrade_casks

        brew_upgrade_casks()

    reinstall_calls = [
        c for c in mock_run.call_args_list if "reinstall" in c.args[0] and "--cask" in c.args[0]
    ]
    assert not reinstall_calls


# ---------------------------------------------------------------------------
# Sudo keep-alive guard around cask reinstalls
# ---------------------------------------------------------------------------


def test_sudo_authenticate_raises_permission_error_on_failure() -> None:
    """_sudo_authenticate must turn a failed/cancelled sudo prompt into PermissionError."""
    from koopa.brew import _sudo_authenticate

    with (
        patch(
            "koopa.brew.subprocess.run",
            side_effect=subprocess.CalledProcessError(1, ["sudo", "-v"]),
        ),
        pytest.raises(PermissionError),
    ):
        _sudo_authenticate()


def test_sudo_keepalive_stops_before_first_refresh() -> None:
    """_sudo_keepalive_stop must join the thread promptly with no refresh call fired.

    The refresh interval is 50s; stopping right after start (as this test does)
    must not block for anywhere close to that.
    """
    from koopa.brew import _sudo_keepalive_start, _sudo_keepalive_stop

    with patch("koopa.brew.subprocess.run") as mock_run:
        handle = _sudo_keepalive_start()
        _sudo_keepalive_stop(handle)

    mock_run.assert_not_called()
    assert not handle[1].is_alive()


def test_brew_upgrade_casks_authenticates_before_reinstalling() -> None:
    """brew_upgrade_casks must authenticate sudo once and keep it alive around the loop."""

    def _side_effect(cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        if "outdated" in cmd and "--cask" in cmd:
            result.stdout = "firefox (128.0 < 129.0)\n"
        else:
            result.stdout = ""
        result.stderr = ""
        result.returncode = 0
        return result

    with (
        patch("koopa.brew.subprocess.run", side_effect=_side_effect),
        patch("koopa.system.has_sudo", return_value=True),
        patch("koopa.brew._sudo_authenticate") as mock_auth,
        patch("koopa.brew._sudo_keepalive_start", return_value="handle") as mock_start,
        patch("koopa.brew._sudo_keepalive_stop") as mock_stop,
    ):
        from koopa.brew import brew_upgrade_casks

        brew_upgrade_casks()

    mock_auth.assert_called_once()
    mock_start.assert_called_once()
    mock_stop.assert_called_once_with("handle")


def test_brew_upgrade_casks_stops_keepalive_even_if_reinstall_fails() -> None:
    """A failed cask reinstall must not leave the sudo keep-alive thread running."""

    def _side_effect(cmd: list[str], **_kwargs: object) -> MagicMock:
        if "reinstall" in cmd:
            raise subprocess.CalledProcessError(1, cmd)
        result = MagicMock()
        if "outdated" in cmd and "--cask" in cmd:
            result.stdout = "firefox (128.0 < 129.0)\n"
        else:
            result.stdout = ""
        result.stderr = ""
        result.returncode = 0
        return result

    with (
        patch("koopa.brew.subprocess.run", side_effect=_side_effect),
        patch("koopa.system.has_sudo", return_value=True),
        patch("koopa.brew._sudo_authenticate"),
        patch("koopa.brew._sudo_keepalive_start", return_value="handle") as mock_start,
        patch("koopa.brew._sudo_keepalive_stop") as mock_stop,
    ):
        from koopa.brew import brew_upgrade_casks

        with pytest.raises(subprocess.CalledProcessError):
            brew_upgrade_casks()

    mock_start.assert_called_once()
    mock_stop.assert_called_once_with("handle")


# ---------------------------------------------------------------------------
# brew_upgrade_brews: one reinstall call per formula, each non-interactive
# ---------------------------------------------------------------------------


def test_brew_upgrade_brews_reinstalls_one_formula_at_a_time() -> None:
    """brew_upgrade_brews must issue one reinstall call per outdated formula.

    A single batched ``brew reinstall --force a b c`` call cannot report a
    live [n/total] counter, since brew only emits progress after every
    formula finishes. Looping gives koopa an exact index to drive the status
    line without parsing brew's output.
    """

    def _side_effect(cmd: list[str], **_kwargs: object) -> MagicMock:
        result = MagicMock()
        if "outdated" in cmd and "--formula" in cmd:
            result.stdout = "gh\njq\nripgrep\n"
        else:
            result.stdout = ""
        result.stderr = ""
        result.returncode = 0
        return result

    with patch("koopa.brew.subprocess.run", side_effect=_side_effect) as mock_run:
        from koopa.brew import brew_upgrade_brews

        brew_upgrade_brews()

    reinstall_calls = [c for c in mock_run.call_args_list if "reinstall" in c.args[0]]
    assert len(reinstall_calls) == 3, "Expected one reinstall call per outdated formula"
    formulae = [c.args[0][-1] for c in reinstall_calls]
    assert formulae == ["gh", "jq", "ripgrep"]
    for c in reinstall_calls:
        kwargs = c.kwargs
        assert kwargs.get("stdin") is subprocess.DEVNULL
        assert kwargs.get("env", {}).get("NONINTERACTIVE") == "1"


# ---------------------------------------------------------------------------
# koopa.progress.set_status / note: safe with no active BuildProgress
# ---------------------------------------------------------------------------


def test_set_status_and_note_noop_without_active_progress() -> None:
    """set_status/note must not raise when no BuildProgress context is active.

    Guards the `koopa app brew-upgrade` CLI path, which calls brew_upgrade()
    directly with no surrounding BuildProgress.
    """
    from koopa.progress import get_active_progress, note, set_status

    assert get_active_progress() is None
    set_status("upgrading brews [1/3] gh")  # must not raise
    with patch("koopa.progress.print") as mock_print:
        note("3 outdated brew(s): gh, jq, ripgrep")
    mock_print.assert_called_once()
    args, kwargs = mock_print.call_args
    assert args[0] == "3 outdated brew(s): gh, jq, ripgrep"
    assert kwargs.get("file") is sys.stderr
