"""Prefix module unit tests."""

from os.path import isdir

import pytest
from koopa.prefix import (
    app_prefix,
    bin_prefix,
    bootstrap_prefix,
    conda_prefix,
    go_prefix,
    koopa_prefix,
    opt_prefix,
)


def test_koopa_prefix_is_directory() -> None:
    """Test koopa_prefix returns an existing directory."""
    assert isdir(koopa_prefix())


def test_koopa_prefix_structure() -> None:
    """Test koopa_prefix path contains expected structure."""
    p = koopa_prefix()
    assert isdir(f"{p}/lang/python")


def test_app_prefix_no_args() -> None:
    """Test app_prefix with no arguments ends with /app."""
    assert app_prefix().endswith("/app")


def test_app_prefix_with_name() -> None:
    """Test app_prefix with name ends with /app/<name>."""
    assert app_prefix("git").endswith("/app/git")


def test_app_prefix_with_name_and_version() -> None:
    """Test app_prefix with name and version."""
    assert app_prefix("git", "2.40").endswith("/app/git/2.40")


def test_bin_prefix() -> None:
    """Test bin_prefix ends with /bin."""
    assert bin_prefix().endswith("/bin")


def test_opt_prefix() -> None:
    """Test opt_prefix ends with /opt."""
    assert opt_prefix().endswith("/opt")


def test_bootstrap_prefix_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test bootstrap_prefix returns env var when set."""
    monkeypatch.setenv("KOOPA_BOOTSTRAP_PREFIX", "/custom/bootstrap")
    assert bootstrap_prefix() == "/custom/bootstrap"


def test_bootstrap_prefix_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test bootstrap_prefix returns default when unset."""
    monkeypatch.delenv("KOOPA_BOOTSTRAP_PREFIX", raising=False)
    assert bootstrap_prefix().endswith("/bootstrap")


def test_conda_prefix_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test conda_prefix returns env var when set."""
    monkeypatch.setenv("CONDA_PREFIX", "/custom/conda")
    assert conda_prefix() == "/custom/conda"


def test_go_prefix_env_set(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test go_prefix returns env var when set."""
    monkeypatch.setenv("GOPATH", "/custom/go")
    assert go_prefix() == "/custom/go"


def test_go_prefix_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test go_prefix returns ~/go when unset."""
    monkeypatch.delenv("GOPATH", raising=False)
    assert go_prefix().endswith("/go")
