"""Tests for koopa.configurers.neovim."""

import subprocess
from pathlib import Path

import pytest
from koopa.configurers import get_python_configurer, has_python_configurer
from koopa.configurers.neovim import main


def test_has_python_configurer_registered() -> None:
    """'neovim' is registered as a common/user configurer."""
    assert has_python_configurer("neovim", "common", "user")


def test_get_python_configurer_resolves_to_main() -> None:
    """Registry resolves 'neovim' to this module's main()."""
    assert get_python_configurer("neovim", "common", "user") is main


def test_has_python_configurer_falls_back_to_common_for_macos_user() -> None:
    """Concrete macos platform falls back to the common registry entry."""
    assert has_python_configurer("neovim", "macos", "user")


def test_main_runs_headless_lazy_sync(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    r"""main() invokes 'nvim --headless \"+Lazy! sync\" +qa'."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.locate", lambda _name: "/usr/bin/nvim")
    monkeypatch.setattr("koopa.configurers.neovim.koopa_prefix", lambda: str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.opt_prefix", lambda: str(tmp_path / "opt"))

    captured: list[list[str]] = []

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        captured.append(args)
        return subprocess.CompletedProcess(args, returncode=0)

    monkeypatch.setattr(subprocess, "run", fake_run)

    main(name="neovim", platform="common", mode="user")

    assert captured == [["/usr/bin/nvim", "--headless", "+Lazy! sync", "+qa"]]


def test_main_raises_as_root(monkeypatch: pytest.MonkeyPatch) -> None:
    """main() refuses to run as root, before touching nvim or the lockfile."""
    monkeypatch.setattr("os.geteuid", lambda: 0)

    with pytest.raises(RuntimeError, match="root"):
        main(name="neovim", platform="common", mode="user")


def test_main_notes_lock_drift(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A changed lazy-lock.json prints the exact 'chezmoi re-add' command."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.locate", lambda _name: "/usr/bin/nvim")
    monkeypatch.setattr("koopa.configurers.neovim.koopa_prefix", lambda: str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.opt_prefix", lambda: str(tmp_path / "opt"))

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0)

    monkeypatch.setattr(subprocess, "run", fake_run)

    nvim_config = tmp_path / ".config" / "nvim"
    nvim_config.mkdir(parents=True)
    (nvim_config / "lazy-lock.json").write_text('{"a": 1}\n')

    source_dir = tmp_path / "opt" / "dotfiles" / "chezmoi" / "dot_config" / "nvim"
    source_dir.mkdir(parents=True)
    (source_dir / "lazy-lock.json").write_text('{"a": 0}\n')

    main(name="neovim", platform="common", mode="user")

    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "chezmoi re-add" in combined
    assert str(nvim_config / "lazy-lock.json") in combined


def test_main_silent_when_lock_unchanged(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """An identical lazy-lock.json prints no drift note."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.locate", lambda _name: "/usr/bin/nvim")
    monkeypatch.setattr("koopa.configurers.neovim.koopa_prefix", lambda: str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.opt_prefix", lambda: str(tmp_path / "opt"))

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0)

    monkeypatch.setattr(subprocess, "run", fake_run)

    nvim_config = tmp_path / ".config" / "nvim"
    nvim_config.mkdir(parents=True)
    (nvim_config / "lazy-lock.json").write_text('{"a": 1}\n')

    source_dir = tmp_path / "opt" / "dotfiles" / "chezmoi" / "dot_config" / "nvim"
    source_dir.mkdir(parents=True)
    (source_dir / "lazy-lock.json").write_text('{"a": 1}\n')

    main(name="neovim", platform="common", mode="user")

    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "chezmoi re-add" not in combined


def test_main_silent_when_no_source_lock(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """No source lockfile at all (not yet versioned) means no drift note."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.locate", lambda _name: "/usr/bin/nvim")
    monkeypatch.setattr("koopa.configurers.neovim.koopa_prefix", lambda: str(tmp_path))
    monkeypatch.setattr("koopa.configurers.neovim.opt_prefix", lambda: str(tmp_path / "opt"))

    def fake_run(args: list[str], **_: object) -> subprocess.CompletedProcess:
        return subprocess.CompletedProcess(args, returncode=0)

    monkeypatch.setattr(subprocess, "run", fake_run)

    nvim_config = tmp_path / ".config" / "nvim"
    nvim_config.mkdir(parents=True)
    (nvim_config / "lazy-lock.json").write_text('{"a": 1}\n')

    main(name="neovim", platform="common", mode="user")

    captured = capsys.readouterr()
    combined = captured.err + captured.out
    assert "chezmoi re-add" not in combined
