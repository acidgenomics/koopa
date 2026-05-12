"""Install module unit tests."""

from unittest.mock import patch


def _make_app_json(installed_name: str, dep_name: str) -> dict:
    """Build a minimal app.json with one app that depends on dep_name."""
    return {
        installed_name: {
            "version": "1.0",
            "dependencies": [dep_name],
        },
        dep_name: {
            "version": "2.0",
        },
    }


def test_apps_with_missing_runtime_deps_clean(tmp_path) -> None:
    """No results when all runtime deps are present in opt/."""
    from koopa.install import _apps_with_missing_runtime_deps

    opt_dir = tmp_path / "opt"
    (opt_dir / "openssl3").mkdir(parents=True)

    json_data = _make_app_json("curl", "openssl3")

    with (
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.installed_apps", return_value=["curl"]),
        patch("koopa.app.os_id", return_value="macos-arm64"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        result = _apps_with_missing_runtime_deps()

    assert result == []


def test_apps_with_missing_runtime_deps_missing(tmp_path) -> None:
    """Dependent is flagged when its runtime dep is absent from opt/."""
    from koopa.install import _apps_with_missing_runtime_deps

    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    # openssl3 is NOT present in opt/

    json_data = _make_app_json("curl", "openssl3")

    with (
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.installed_apps", return_value=["curl"]),
        patch("koopa.app.os_id", return_value="macos-arm64"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        result = _apps_with_missing_runtime_deps()

    assert result == [("curl", "dependency openssl3 removed")]


def test_apps_with_missing_runtime_deps_skips_removed(tmp_path) -> None:
    """Apps marked removed: true are not reported as needing rebuild."""
    from koopa.install import _apps_with_missing_runtime_deps

    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()

    json_data = {
        "curl": {
            "version": "1.0",
            "removed": True,
            "dependencies": ["openssl3"],
        },
        "openssl3": {"version": "2.0"},
    }

    with (
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.installed_apps", return_value=["curl"]),
        patch("koopa.app.os_id", return_value="macos-arm64"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        result = _apps_with_missing_runtime_deps()

    assert result == []


def test_apps_with_missing_runtime_deps_alias_resolved(tmp_path) -> None:
    """Alias-of entries are resolved before checking opt/."""
    from koopa.install import _apps_with_missing_runtime_deps

    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    # The canonical name openssl4 IS present; the alias openssl is not.
    (opt_dir / "openssl4").mkdir()

    json_data = {
        "curl": {
            "version": "1.0",
            "dependencies": ["openssl"],
        },
        "openssl": {"alias_of": "openssl4"},
        "openssl4": {"version": "3.0"},
    }

    with (
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.installed_apps", return_value=["curl"]),
        patch("koopa.app.os_id", return_value="macos-arm64"),
        patch("koopa.app.import_app_json", return_value=json_data),
    ):
        result = _apps_with_missing_runtime_deps()

    # openssl4 exists in opt/, so curl should NOT be flagged.
    assert result == []
