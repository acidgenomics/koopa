"""Tests for the Go module-download network defaults."""

from __future__ import annotations

from typing import TYPE_CHECKING
from unittest.mock import patch

from koopa.system import go_network_env

if TYPE_CHECKING:
    from pathlib import Path

    import pytest


def test_defaults_are_set() -> None:
    """GOPROXY falls back on any error and Go uses HTTP/1.1."""
    env: dict[str, str] = {}
    go_network_env(env)
    assert env["GOPROXY"] == "https://proxy.golang.org|direct"
    assert env["GODEBUG"] == "http2client=0"


def test_preset_goproxy_is_preserved() -> None:
    """A user mirror always wins over the default."""
    env = {"GOPROXY": "https://mirror.example/go"}
    go_network_env(env)
    assert env["GOPROXY"] == "https://mirror.example/go"


def test_godebug_is_merged_once() -> None:
    """Existing GODEBUG settings are kept and http2client is never duplicated."""
    env = {"GODEBUG": "madvdontneed=1"}
    go_network_env(env)
    assert env["GODEBUG"] == "madvdontneed=1,http2client=0"
    go_network_env(env)
    assert env["GODEBUG"] == "madvdontneed=1,http2client=0"


def test_user_http2client_setting_is_preserved() -> None:
    """A user who chose http2client=1 is not overridden."""
    env = {"GODEBUG": "http2client=1"}
    go_network_env(env)
    assert env["GODEBUG"] == "http2client=1"


def test_go_install_helpers_pass_defaults(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Both Go install helpers hand the defaults to the go subprocess."""
    from koopa import install

    monkeypatch.delenv("GOPROXY", raising=False)
    monkeypatch.delenv("GODEBUG", raising=False)
    monkeypatch.setattr(install.shutil, "which", lambda _name: "/usr/bin/go")
    with patch("koopa.install.subprocess.run") as run:
        install.install_go_package(url="example.test/cmd@v1", prefix=str(tmp_path))
    env = run.call_args.kwargs["env"]
    assert env["GOPROXY"] == "https://proxy.golang.org|direct"
    assert env["GODEBUG"] == "http2client=0"
