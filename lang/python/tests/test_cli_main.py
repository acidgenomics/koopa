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
        cli_main._handle_update(argparse.Namespace(mode=None, verbose=False, system=False))

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
