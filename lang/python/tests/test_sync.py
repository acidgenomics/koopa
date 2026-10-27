"""Tests for default-app synchronization."""

from unittest.mock import patch

import pytest
from koopa import uninstall


def test_sync_default_apps_installs_then_removes_non_defaults() -> None:
    """Missing defaults are installed before non-default apps are removed."""
    removed: list[str] = []
    with (
        patch("koopa.app.default_app_closure", return_value={"default", "dependency"}),
        patch("koopa.app.installed_apps", return_value=["default", "dependency", "extra"]),
        patch("koopa.install.install_missing_default_apps") as install_missing,
        patch("koopa.install._acquire_install_lock", return_value=True),
        patch("koopa.install._release_install_lock") as release_lock,
        patch(
            "koopa.uninstall.uninstall_app",
            side_effect=lambda config: removed.append(config.name),
        ),
    ):
        uninstall.sync_default_apps(yes=True, verbose=True)

    install_missing.assert_called_once_with(verbose=True)
    assert removed == ["extra"]
    release_lock.assert_called_once()


def test_sync_default_apps_dry_run_only_lists_removals(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Dry run previews removals without invoking install or uninstall paths."""
    with (
        patch("koopa.app.default_app_closure", return_value={"default"}),
        patch("koopa.app.installed_apps", return_value=["default", "extra"]),
        patch("koopa.install.install_missing_default_apps") as install_missing,
        patch("koopa.uninstall.uninstall_app") as uninstall_app,
    ):
        uninstall.sync_default_apps(dry_run=True)

    assert "Apps to remove (1):" in capsys.readouterr().out
    install_missing.assert_not_called()
    uninstall_app.assert_not_called()


def test_sync_default_apps_does_not_prune_after_install_failure() -> None:
    """A failed default installation prevents the destructive prune phase."""
    with (
        patch("koopa.app.default_app_closure", return_value={"default"}),
        patch(
            "koopa.install.install_missing_default_apps",
            side_effect=RuntimeError("default installation failed"),
        ),
        patch("koopa.uninstall.uninstall_app") as uninstall_app,
        pytest.raises(RuntimeError, match="default installation failed"),
    ):
        uninstall.sync_default_apps(yes=True)

    uninstall_app.assert_not_called()


def test_sync_default_apps_respects_confirmation(monkeypatch: pytest.MonkeyPatch) -> None:
    """A declined confirmation leaves non-default apps installed."""

    class _Stdin:
        @staticmethod
        def isatty() -> bool:
            return True

    monkeypatch.setattr(uninstall.sys, "stdin", _Stdin())
    with (
        patch("koopa.app.default_app_closure", return_value={"default"}),
        patch("koopa.app.installed_apps", return_value=["default", "extra"]),
        patch("koopa.install.install_missing_default_apps"),
        patch("builtins.input", return_value="n"),
        patch("koopa.uninstall.uninstall_app") as uninstall_app,
    ):
        uninstall.sync_default_apps()

    uninstall_app.assert_not_called()
