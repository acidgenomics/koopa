"""CLI entry point unit tests."""

from __future__ import annotations

import argparse
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa import cli_main


def test_handle_update_skips_system_updates_by_default(monkeypatch: pytest.MonkeyPatch) -> None:
    """Default update should not trigger system upgrades."""
    monkeypatch.setattr(cli_main, "_require_supported_platform", lambda: None)
    monkeypatch.setattr(cli_main, "_require_git_managed_install", lambda: None)
    monkeypatch.setattr(cli_main, "_require_slurm_allocation", lambda: None)
    monkeypatch.setattr(cli_main, "_koopa_prefix", lambda: "/tmp/koopa")

    with (
        patch("koopa.install._acquire_install_lock", return_value=True),
        patch("koopa.install._cleanup_legacy_config"),
        patch("koopa.install._release_install_lock"),
        patch("koopa.install._update_venv"),
        patch("koopa.install.install_missing_default_apps"),
        patch("koopa.install.remove_alias_app_dirs"),
        patch("koopa.install.remove_unsupported_apps"),
        patch("koopa.install.repair_app_symlinks"),
        patch("koopa.install.update_bootstrap", return_value=False),
        patch("koopa.install.update_koopa", return_value=False),
        patch("koopa.install.update_stale_apps"),
        patch("koopa.app.prune_apps"),
        patch("koopa.install.update_system_apps") as update_system_apps,
    ):
        cli_main._handle_update(argparse.Namespace(mode=None, apps=[], verbose=False, system=False))

    update_system_apps.assert_not_called()


def test_update_parser_accepts_system_mode() -> None:
    """The CLI should support an explicit system-update mode."""
    parser = cli_main._build_parser()
    args = parser.parse_args(["update", "system"])

    assert args.command == "update"
    assert args.mode == "system"


def test_require_git_managed_install_permits_pinned_release(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A pinned-release (tarball, no '.git') koopa tree still permits app management.

    Regression test: the gate used to require a git repo on a non-detached
    branch, which also rejected a tarball-extracted pinned release -- exactly
    what 'koopa.acidgenomics.com/install --version=X' produces.
    """
    (tmp_path / "lang" / "python" / "src").mkdir(parents=True)
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    cli_main._require_git_managed_install()  # must not raise or exit


def test_require_git_managed_install_refuses_packaged_install(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A site-packages/conda install (no 'lang/python/src' tree) is refused."""
    monkeypatch.setattr("koopa.prefix.koopa_prefix", lambda: str(tmp_path))

    with pytest.raises(SystemExit):
        cli_main._require_git_managed_install()


def test_require_slurm_allocation_refuses_bare_login_shell(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A Slurm submit host with no active job allocation is refused."""
    monkeypatch.delenv("KOOPA_ALLOW_SLURM_SUBMIT_HOST", raising=False)
    monkeypatch.setattr("koopa.system.is_slurm_submit_host", lambda: True)
    monkeypatch.setattr("koopa.system.in_slurm_allocation", lambda: False)

    with pytest.raises(SystemExit):
        cli_main._require_slurm_allocation()


def test_require_slurm_allocation_permits_inside_allocation(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A shell started via 'salloc'/'srun'/'sbatch' is never blocked."""
    monkeypatch.delenv("KOOPA_ALLOW_SLURM_SUBMIT_HOST", raising=False)
    monkeypatch.setattr("koopa.system.is_slurm_submit_host", lambda: True)
    monkeypatch.setattr("koopa.system.in_slurm_allocation", lambda: True)

    cli_main._require_slurm_allocation()  # must not raise or exit


def test_require_slurm_allocation_permits_non_slurm_host(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A workstation with no Slurm tooling is never blocked."""
    monkeypatch.delenv("KOOPA_ALLOW_SLURM_SUBMIT_HOST", raising=False)
    monkeypatch.setattr("koopa.system.is_slurm_submit_host", lambda: False)
    monkeypatch.setattr("koopa.system.in_slurm_allocation", lambda: False)

    cli_main._require_slurm_allocation()  # must not raise or exit


def test_require_slurm_allocation_env_override_short_circuits(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """'KOOPA_ALLOW_SLURM_SUBMIT_HOST=1' bypasses the check without probing Slurm."""
    monkeypatch.setenv("KOOPA_ALLOW_SLURM_SUBMIT_HOST", "1")

    def _unexpected_call() -> bool:
        raise AssertionError("is_slurm_submit_host should not be called under the override")

    monkeypatch.setattr("koopa.system.is_slurm_submit_host", _unexpected_call)

    cli_main._require_slurm_allocation()  # must not raise or exit


def test_revert_direnv_env_reports_count_when_verbose(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture
) -> None:
    """A verbose note names the project dir and reports how many vars were reverted."""
    monkeypatch.setenv("DIRENV_DIR", "-/Users/someuser/some-project")
    with patch("koopa.system.revert_direnv_env", return_value=["FOO", "BAR"]):
        cli_main._revert_direnv_env(verbose=True)

    err = capsys.readouterr().err
    assert "/Users/someuser/some-project" in err
    assert "2" in err


def test_revert_direnv_env_reports_project_dir_when_it_is_itself_reverted(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture
) -> None:
    """The note still names the project dir when 'DIRENV_DIR' is one of the reverted vars.

    'DIRENV_DIR' is itself absent from direnv's pre-'.envrc' state, so the real
    'revert_direnv_env' removes it from 'os.environ' along with every other var
    direnv set. A mock that doesn't reproduce that removal (see
    'test_revert_direnv_env_reports_count_when_verbose') can't catch a read
    that happens after the removal instead of before it.
    """
    monkeypatch.setenv("DIRENV_DIR", "-/Users/someuser/some-project")

    def _fake_revert() -> list[str]:
        monkeypatch.delenv("DIRENV_DIR", raising=False)
        return ["DIRENV_DIR", "FOO"]

    with patch("koopa.system.revert_direnv_env", side_effect=_fake_revert):
        cli_main._revert_direnv_env(verbose=True)

    err = capsys.readouterr().err
    assert "/Users/someuser/some-project" in err
    assert "2" in err


def test_revert_direnv_env_silent_by_default(capsys: pytest.CaptureFixture) -> None:
    """No message prints without '--verbose', even when vars were reverted."""
    with patch("koopa.system.revert_direnv_env", return_value=["FOO"]):
        cli_main._revert_direnv_env(verbose=False)

    assert capsys.readouterr().err == ""


def test_revert_direnv_env_silent_when_nothing_reverted(
    capsys: pytest.CaptureFixture,
) -> None:
    """No message prints under '--verbose' when direnv wasn't active."""
    with patch("koopa.system.revert_direnv_env", return_value=[]):
        cli_main._revert_direnv_env(verbose=True)

    assert capsys.readouterr().err == ""
