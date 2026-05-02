"""XDG module unit tests."""

import os

import pytest
from koopa.xdg import (
    xdg_cache_home,
    xdg_config_dirs,
    xdg_config_home,
    xdg_data_dirs,
    xdg_data_home,
    xdg_local_home,
    xdg_state_home,
)


def test_xdg_cache_home_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_cache_home returns env var when set."""
    monkeypatch.setenv("XDG_CACHE_HOME", "/custom/cache")
    assert xdg_cache_home() == "/custom/cache"


def test_xdg_cache_home_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_cache_home returns default when unset."""
    monkeypatch.delenv("XDG_CACHE_HOME", raising=False)
    assert xdg_cache_home() == os.path.expanduser("~/.cache")


def test_xdg_config_dirs_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_config_dirs splits on colon."""
    monkeypatch.setenv("XDG_CONFIG_DIRS", "/a:/b:/c")
    assert xdg_config_dirs() == ["/a", "/b", "/c"]


def test_xdg_config_dirs_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_config_dirs returns default when unset."""
    monkeypatch.delenv("XDG_CONFIG_DIRS", raising=False)
    assert xdg_config_dirs() == ["/etc/xdg"]


def test_xdg_config_home_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_config_home returns env var when set."""
    monkeypatch.setenv("XDG_CONFIG_HOME", "/custom/config")
    assert xdg_config_home() == "/custom/config"


def test_xdg_config_home_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_config_home returns default when unset."""
    monkeypatch.delenv("XDG_CONFIG_HOME", raising=False)
    assert xdg_config_home() == os.path.expanduser("~/.config")


def test_xdg_data_dirs_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_data_dirs splits on colon."""
    monkeypatch.setenv("XDG_DATA_DIRS", "/x:/y")
    assert xdg_data_dirs() == ["/x", "/y"]


def test_xdg_data_dirs_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_data_dirs returns default when unset."""
    monkeypatch.delenv("XDG_DATA_DIRS", raising=False)
    assert xdg_data_dirs() == ["/usr/local/share", "/usr/share"]


def test_xdg_data_home_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_data_home returns env var when set."""
    monkeypatch.setenv("XDG_DATA_HOME", "/custom/data")
    assert xdg_data_home() == "/custom/data"


def test_xdg_data_home_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_data_home returns default when unset."""
    monkeypatch.delenv("XDG_DATA_HOME", raising=False)
    assert xdg_data_home() == os.path.expanduser("~/.local/share")


def test_xdg_local_home() -> None:
    """Test xdg_local_home returns ~/.local."""
    assert xdg_local_home() == os.path.expanduser("~/.local")


def test_xdg_state_home_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_state_home returns env var when set."""
    monkeypatch.setenv("XDG_STATE_HOME", "/custom/state")
    assert xdg_state_home() == "/custom/state"


def test_xdg_state_home_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test xdg_state_home returns default when unset."""
    monkeypatch.delenv("XDG_STATE_HOME", raising=False)
    assert xdg_state_home() == os.path.expanduser("~/.local/state")
