"""Tests for koopa.configurers.vim."""

import os
import shutil
import subprocess
from pathlib import Path

import pytest
from koopa.configurers import get_python_configurer, has_python_configurer
from koopa.configurers.vim import main


def test_has_python_configurer_registered() -> None:
    """'vim' is registered as a common/user configurer."""
    assert has_python_configurer("vim", "common", "user")


def test_get_python_configurer_resolves_to_main() -> None:
    """Registry resolves 'vim' to this module's main()."""
    assert get_python_configurer("vim", "common", "user") is main


def test_has_python_configurer_falls_back_to_common_for_macos_user() -> None:
    """Concrete macos platform falls back to the common registry entry."""
    assert has_python_configurer("vim", "macos", "user")


def test_main_runs_headless_plugin_update(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
) -> None:
    """main() runs vim-plug synchronously and fails if a plugin update failed."""
    monkeypatch.setenv("HOME", str(tmp_path))
    (tmp_path / ".vimrc").touch()
    monkeypatch.setattr("koopa.configurers.vim.locate", lambda _name: "/usr/bin/vim")
    monkeypatch.setattr("koopa.configurers.vim.koopa_prefix", lambda: str(tmp_path))

    captured: list[list[str]] = []
    captured_env: list[dict[str, str]] = []

    def fake_run(
        args: list[str],
        *,
        check: bool,
        capture_output: bool,
        text: bool,
        env: dict[str, str],
    ) -> subprocess.CompletedProcess:
        captured.append(args)
        captured_env.append(env)
        assert check
        assert capture_output
        assert text
        return subprocess.CompletedProcess(args, returncode=0)

    monkeypatch.setattr(subprocess, "run", fake_run)

    main(name="vim", platform="common", mode="user")

    assert captured == [
        [
            "/usr/bin/vim",
            "-es",
            "-n",
            "-i",
            "NONE",
            "-u",
            str(tmp_path / ".vimrc"),
            "-V1",
            "-c",
            "PlugUpdate --sync",
            "-c",
            "call writefile(getline(1, '$'), '/dev/stdout', 'a')",
            "-c",
            "if search('^x ', 'nw') | cquit 1 | endif",
            "-c",
            "qa!",
        ]
    ]
    assert captured_env[0]["PATH"].startswith(f"{tmp_path}/bin{os.pathsep}")


def test_main_prints_report_when_plugin_update_fails(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    tmp_path: Path,
) -> None:
    """main() prints vim-plug's report before surfacing a failed update."""
    monkeypatch.setenv("HOME", str(tmp_path))
    (tmp_path / ".vimrc").touch()
    monkeypatch.setattr("koopa.configurers.vim.locate", lambda _name: "/usr/bin/vim")
    monkeypatch.setattr("koopa.configurers.vim.koopa_prefix", lambda: "/opt/koopa")
    output = "x rust.vim:\n    merge: origin/master - not something we can merge\n"

    def fake_run(
        args: list[str],
        *,
        check: bool,
        capture_output: bool,
        text: bool,
        env: dict[str, str],
    ) -> subprocess.CompletedProcess:
        assert check
        assert capture_output
        assert text
        raise subprocess.CalledProcessError(1, args, output=output, stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)

    with pytest.raises(RuntimeError, match="Vim plugin update failed"):
        main(name="vim", platform="common", mode="user")

    assert output in capsys.readouterr().out


@pytest.mark.parametrize("failed", [False, True])
def test_headless_vim_loads_configuration_and_reports_result(
    monkeypatch: pytest.MonkeyPatch,
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    failed: bool,
) -> None:
    """Run real Vim with an isolated fake vim-plug command."""
    vim = shutil.which("vim")
    if vim is None:
        pytest.skip("Vim is not installed")
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr("koopa.configurers.vim.locate", lambda _name: vim)
    monkeypatch.setattr("koopa.configurers.vim.koopa_prefix", lambda: str(tmp_path))
    report = "x example: update failed" if failed else "- example: updated"
    (tmp_path / ".vimrc").write_text(
        f"set nocompatible\ncommand! -nargs=* PlugUpdate call setline(1, ['{report}'])\n"
    )
    if failed:
        with pytest.raises(RuntimeError, match="Vim plugin update failed"):
            main(name="vim", platform="common", mode="user")
    else:
        main(name="vim", platform="common", mode="user")
    assert report in capsys.readouterr().out


def test_missing_vimrc_is_reported(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """A missing configuration does not silently run Vim without plugins."""
    monkeypatch.setenv("HOME", str(tmp_path))
    with pytest.raises(FileNotFoundError, match="Vim configuration not found"):
        main(name="vim", platform="common", mode="user")


def test_main_raises_as_root(monkeypatch: pytest.MonkeyPatch) -> None:
    """main() refuses to run as root."""
    monkeypatch.setattr("os.geteuid", lambda: 0)

    with pytest.raises(RuntimeError, match="root"):
        main(name="vim", platform="common", mode="user")
