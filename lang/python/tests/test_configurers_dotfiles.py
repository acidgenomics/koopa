"""Tests for koopa.configurers.dotfiles helpers."""

import subprocess
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.configurers import get_python_configurer, has_python_configurer
from koopa.configurers.dotfiles import (
    _chezmoi_managed,
    _print_chezmoi_status,
    _warn_cross_tree_overlap,
    main,
)


def test_has_python_configurer_falls_back_to_common_for_macos_user() -> None:
    """Concrete macos platform falls back to the common registry entry."""
    assert has_python_configurer("dotfiles", "macos", "user")
    assert has_python_configurer("color-mode", "macos", "user")


def test_get_python_configurer_falls_back_to_common_for_macos_user() -> None:
    """Concrete macos platform resolves to the common configurer's module."""
    assert get_python_configurer("dotfiles", "macos", "user") is main


def test_has_python_configurer_expands_common_to_os_id_like_family() -> None:
    """Generic common platform expands to the host's ID_LIKE family."""
    with (
        patch("koopa.system.get_os_id", return_value="ubuntu"),
        patch("koopa.system.get_os_id_like", return_value="debian"),
        patch("koopa.system.is_macos", return_value=False),
    ):
        assert has_python_configurer("base", "common", "system")


# ---------------------------------------------------------------------------
# _warn_cross_tree_overlap
# ---------------------------------------------------------------------------


def test_warn_cross_tree_overlap_empty(capsys: pytest.CaptureFixture[str]) -> None:
    """No warning when there is no overlap."""
    _warn_cross_tree_overlap("work", {".bashrc", ".config/git/config"}, {".bashrc-work"})
    captured = capsys.readouterr()
    assert "Warning" not in captured.err
    assert "Warning" not in captured.out


def test_warn_cross_tree_overlap_nonempty(capsys: pytest.CaptureFixture[str]) -> None:
    """Warning lists every colliding path when overlap is non-empty."""
    main = {".bashrc", ".config/git/config", ".npmrc"}
    work = {".bashrc", ".npmrc", ".bashrc-work"}
    _warn_cross_tree_overlap("work", main, work)
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Warning" in combined
    assert ".bashrc" in combined
    assert ".npmrc" in combined
    assert ".config/git/config" not in combined  # not in overlap


def test_warn_cross_tree_overlap_label(capsys: pytest.CaptureFixture[str]) -> None:
    """Warning includes the tree label."""
    _warn_cross_tree_overlap("private", {".zshrc"}, {".zshrc"})
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "private" in combined


def test_warn_cross_tree_overlap_count(capsys: pytest.CaptureFixture[str]) -> None:
    """Warning reports the correct collision count."""
    overlap = {".a", ".b", ".c"}
    _warn_cross_tree_overlap("work", overlap, overlap)
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "3" in combined


# ---------------------------------------------------------------------------
# _chezmoi_managed
# ---------------------------------------------------------------------------


def test_chezmoi_managed_absent_source(tmp_path: Path) -> None:
    """Returns empty set without calling subprocess when source dir is absent."""
    result = _chezmoi_managed("/usr/bin/chezmoi", str(tmp_path / "nonexistent"), {})
    assert result == set()


def test_chezmoi_managed_parses_stdout(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Parses stdout into a stripped set; blank lines are dropped."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    fake_output = ".bashrc\n.config/git/config\n\n  .npmrc  \n"

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout=fake_output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_managed("/usr/bin/chezmoi", str(source), {})
    assert result == {".bashrc", ".config/git/config", ".npmrc"}


def test_chezmoi_managed_subprocess_error(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Returns empty set on CalledProcessError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        raise subprocess.CalledProcessError(1, args)

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_managed("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoi_managed_oserror(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Returns empty set on OSError — never raises."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(_args: list[str], **__: object) -> subprocess.CompletedProcess:
        raise OSError("not found")

    monkeypatch.setattr(subprocess, "run", fake_run)
    result = _chezmoi_managed("/usr/bin/chezmoi", str(source), {})
    assert result == set()


def test_chezmoi_managed_passes_config(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Passes --config= to argv when config is provided."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoi_managed("/usr/bin/chezmoi", str(source), {}, config="/some/chezmoi.toml")
    assert any("--config=/some/chezmoi.toml" in a for a in captured_args[0])


def test_chezmoi_managed_omits_config_when_none(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Does not include --config= in argv when config is None."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    captured_args: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured_args.append(list(args))
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _chezmoi_managed("/usr/bin/chezmoi", str(source), {}, config=None)
    assert not any("--config" in a for a in captured_args[0])


# ---------------------------------------------------------------------------
# _print_chezmoi_status
# ---------------------------------------------------------------------------


def test_print_chezmoi_status_absent_source(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """No output when source dir is absent."""
    _print_chezmoi_status("/usr/bin/chezmoi", str(tmp_path / "nonexistent"), {})
    captured = capsys.readouterr()
    assert captured.err == ""
    assert captured.out == ""


def test_print_chezmoi_status_no_changes(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Emits 'No pending changes' note when status output is empty."""
    source = tmp_path / "chezmoi"
    source.mkdir()

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout="", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _print_chezmoi_status("/usr/bin/chezmoi", str(source), {})
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "No pending changes" in combined


def test_print_chezmoi_status_with_changes(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Emits 'Pending changes (N)' header and each status line."""
    source = tmp_path / "chezmoi"
    source.mkdir()
    fake_output = "MM .config/git/config\n M .bashrc\n"

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0, stdout=fake_output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)
    _print_chezmoi_status("/usr/bin/chezmoi", str(source), {})
    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "Pending changes (2)" in combined
    assert ".config/git/config" in combined
    assert ".bashrc" in combined
