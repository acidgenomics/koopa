"""Check module unit tests."""

from pathlib import Path
from unittest.mock import patch


def _write_json(path: Path, data: dict) -> None:
    import json

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data))


def _link_app(opt_dir: Path, app_dir: Path, name: str, version: str) -> Path:
    """Create app/<name>/<version> and symlink opt/<name> to it. Returns the version dir."""
    version_dir = app_dir / name / version
    version_dir.mkdir(parents=True)
    (opt_dir / name).symlink_to(version_dir)
    return version_dir


def _dep_issue(tmp_path: Path, dep_version: str, dep_revision: str | None, info: dict) -> list:
    """Set up myapp -> dep and return actionable issues for myapp.

    myapp is linked at version 1.0 with the given .install/info.json. dep is
    linked at *dep_version*, optionally with a .install/revision file.
    """
    from koopa.check import _iter_installed_app_issues

    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    app_dir = tmp_path / "app"
    app_dir.mkdir()

    myapp_dir = _link_app(opt_dir, app_dir, "myapp", "1.0")
    _write_json(myapp_dir / ".install" / "info.json", info)

    dep_dir = _link_app(opt_dir, app_dir, "dep", dep_version)
    if dep_revision is not None:
        (dep_dir / ".install").mkdir()
        (dep_dir / ".install" / "revision").write_text(dep_revision)

    json_data = {
        "myapp": {"version": "1.0", "dependencies": ["dep"]},
        "dep": {"version": "9.9"},  # app.json target; must never be consulted for staleness
    }

    with (
        patch("koopa.check.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.check.import_app_json", return_value=json_data),
        patch("koopa.check.installed_apps", return_value=["myapp"]),
        patch("koopa.system.os_id", return_value="macos-arm64"),
    ):
        issues = _iter_installed_app_issues()

    return [(n, r) for n, r, actionable in issues if n == "myapp" and actionable]


def test_dep_version_bumped_in_app_json_only_not_flagged(tmp_path: Path) -> None:
    """A dep bumped in app.json but not yet rebuilt on disk doesn't flag dependents.

    Regression test: app.json's target dep version ("9.9" here) must never be
    compared against the recorded value. Only the installed dep (2.0) matters.
    """
    issues = _dep_issue(
        tmp_path,
        dep_version="2.0",
        dep_revision=None,
        info={"dep_versions": {"dep": "2.0"}, "dep_revisions": {}},
    )
    assert issues == []


def test_dep_version_changed_on_disk_flagged(tmp_path: Path) -> None:
    """A dep installed at a different version than recorded flags the dependent."""
    issues = _dep_issue(
        tmp_path,
        dep_version="3.0",
        dep_revision=None,
        info={"dep_versions": {"dep": "2.0"}, "dep_revisions": {}},
    )
    assert len(issues) == 1
    assert issues[0][1] == "myapp dependency dep version changed: 2.0 -> 3.0"


def test_dep_revision_bumped_on_disk_flagged(tmp_path: Path) -> None:
    """A dep rebuilt at a higher revision (same version) flags the dependent."""
    issues = _dep_issue(
        tmp_path,
        dep_version="2.0",
        dep_revision="2",
        info={"dep_versions": {"dep": "2.0"}, "dep_revisions": {"dep": 1}},
    )
    assert len(issues) == 1
    assert issues[0][1] == "myapp dependency dep revised: 1 -> 2"


def test_recorded_empty_deps_not_flagged_by_firewall_dict_reresolution(
    tmp_path: Path,
) -> None:
    """A dict-typed dependency re-resolved under a different context isn't flagged.

    Regression test: myapp was installed under a plain shell, where a
    firewall_linux/firewall_macos/default dependency dict resolved to an empty
    "default" list (recorded in info.json). Re-running the check from a builder
    shell (or behind a firewall) re-resolves the *same* dict to the
    firewall branch and invents a "dep" dependency myapp never linked against.
    Since myapp's recorded dependency list ([]) is authoritative, "dep" being
    revised on disk must not flag myapp.
    """
    from koopa.check import _iter_installed_app_issues

    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    app_dir = tmp_path / "app"
    app_dir.mkdir()

    myapp_dir = _link_app(opt_dir, app_dir, "myapp", "1.0")
    _write_json(
        myapp_dir / ".install" / "info.json",
        {"dependencies": [], "dep_versions": {}, "dep_revisions": {}},
    )

    dep_dir = _link_app(opt_dir, app_dir, "dep", "1.0")
    (dep_dir / ".install").mkdir()
    (dep_dir / ".install" / "revision").write_text("2")

    json_data = {
        "myapp": {
            "version": "1.0",
            "dependencies": {"default": [], "firewall_linux": ["dep"], "firewall_macos": ["dep"]},
        },
        "dep": {"version": "1.0", "revision": 2},
    }

    with (
        patch("koopa.check.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.check.import_app_json", return_value=json_data),
        patch("koopa.check.installed_apps", return_value=["myapp"]),
        patch("koopa.system.os_id", return_value="macos-arm64"),
        patch("koopa.system.has_firewall", return_value=True),
    ):
        issues = _iter_installed_app_issues()

    actionable = [(n, r) for n, r, actionable in issues if n == "myapp" and actionable]
    assert actionable == []


def test_dep_sha_version_normalized_before_compare(tmp_path: Path) -> None:
    """A recorded 40-char SHA and an installed 7-char dir are treated as equal."""
    sha = "a" * 40
    issues = _dep_issue(
        tmp_path,
        dep_version=sha[:7],
        dep_revision=None,
        info={"dep_versions": {"dep": sha}, "dep_revisions": {}},
    )
    assert issues == []
