"""Tests for preserving Python app environments across interpreter rebuilds."""

import json
import shutil
import subprocess
import sys
from pathlib import Path
from unittest.mock import patch

import pytest
from koopa.app import stale_revdep_closure
from koopa.check import _iter_installed_app_issues
from koopa.install import _obsolete_python_venv_rebuild, update_stale_apps
from koopa.venv_rebuild import can_preserve_python_venv


@pytest.fixture
def venv_apps(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> tuple[Path, dict]:
    """Create a stable opt-linked Python and an installed dependent venv."""
    opt = tmp_path / "opt"
    opt.mkdir()
    apps = tmp_path / "app"
    python = apps / "python3.14" / "3.14.10"
    (python / "bin").mkdir(parents=True)
    (python / "bin" / "python3.14").write_text("python")
    (python / ".install").mkdir()
    (python / ".install" / "info.json").write_text(
        json.dumps({"date": "2026-11-02 00:00:00", "dependencies": ["libffi"]})
    )
    (opt / "python3.14").symlink_to(python)
    app = apps / "myapp" / "1.0"
    venv = app / "libexec"
    (venv / "bin").mkdir(parents=True)
    (venv / "bin" / "python3.14").symlink_to(opt / "python3.14" / "bin" / "python3.14")
    (venv / "lib" / "python3.14" / "site-packages").mkdir(parents=True)
    (venv / "pyvenv.cfg").write_text(f"home = {opt}/python3.14/bin\nversion = 3.14.10\n")
    (app / ".install").mkdir()
    (app / ".install" / "info.json").write_text(
        json.dumps(
            {
                "date": "2026-11-01 00:00:00",
                "dependencies": ["python"],
                "dep_versions": {"python3.14": "3.14.10"},
                "dep_revisions": {},
            }
        )
    )
    (opt / "myapp").symlink_to(app)
    registry = {
        "libffi": {"version": "3.8"},
        "python": {"alias_of": "python3.14"},
        "python3.14": {"version": "3.14.10", "dependencies": ["libffi"]},
        "myapp": {
            "version": "1.0",
            "installer": "python-package",
            "dependencies": ["python"],
        },
    }
    monkeypatch.setattr("koopa.venv_rebuild.opt_prefix", lambda: str(opt))
    monkeypatch.setattr("koopa.venv_rebuild.os_id", lambda: "macos-arm64")
    return opt, registry


def test_same_version_venv_is_preserved(venv_apps: tuple[Path, dict]) -> None:
    """Keep a known pure-Python environment on a same-version rebuild."""
    _, registry = venv_apps
    assert can_preserve_python_venv("myapp", "python3.14", registry)


@pytest.mark.parametrize(
    "change",
    ["target", "recorded", "revision", "metadata", "link", "config", "native", "binary", "path"],
)
def test_uncertain_or_changed_venv_is_rebuilt(venv_apps: tuple[Path, dict], change: str) -> None:
    """Do not preserve changed, incomplete or native environments."""
    opt, registry = venv_apps
    info_path = opt / "myapp" / ".install" / "info.json"
    if change == "target":
        registry["python3.14"]["version"] = "3.14.11"
    elif change == "recorded":
        info = json.loads(info_path.read_text())
        info["dep_versions"]["python3.14"] = "3.14.9"
        info_path.write_text(json.dumps(info))
    elif change == "revision":
        registry["python3.14"]["revision"] = 1
    elif change == "metadata":
        info_path.unlink()
    elif change == "link":
        link = opt / "myapp" / "libexec" / "bin" / "python3.14"
        link.unlink()
        link.symlink_to(opt / "python3.14" / "missing")
    elif change == "config":
        (opt / "myapp" / "libexec" / "pyvenv.cfg").write_text("home = /elsewhere\n")
    elif change == "native":
        native = opt / "myapp" / "libexec" / "lib" / "python3.14" / "site-packages" / "native.so"
        native.touch()
    elif change == "binary":
        binary = opt / "myapp" / "libexec" / "bin" / "tool"
        binary.write_bytes(b"\x7fELF")
        binary.chmod(0o755)
    else:
        path_file = opt / "myapp" / "libexec" / "lib" / "python3.14" / "site-packages" / "extra.pth"
        path_file.write_text("/unknown\n")
    assert not can_preserve_python_venv("myapp", "python3.14", registry)


def test_reverse_dependency_closure_skips_only_compatible_edge(
    venv_apps: tuple[Path, dict],
) -> None:
    """A transitive Python rebuild leaves only a compatible venv untouched."""
    opt, registry = venv_apps
    with (
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt)),
        patch("koopa.app.import_app_json", return_value=registry),
        patch("koopa.app.installed_apps", return_value=["python3.14", "myapp"]),
    ):
        assert stale_revdep_closure(["libffi"]) == {"python3.14": ["libffi"]}
        registry["python3.14"]["version"] = "3.14.11"
        assert stale_revdep_closure(["libffi"]) == {
            "python3.14": ["libffi"],
            "myapp": ["python3.14"],
        }


def test_check_ignores_only_compatible_python_rebuild(venv_apps: tuple[Path, dict]) -> None:
    """Stale checks retain the conservative behavior when Python will change."""
    opt, registry = venv_apps
    with (
        patch("koopa.check.opt_prefix", return_value=str(opt)),
        patch("koopa.check.import_app_json", return_value=registry),
        patch("koopa.check.installed_apps", return_value=["myapp"]),
        patch("koopa.system.os_id", return_value="macos-arm64"),
    ):
        assert _iter_installed_app_issues() == []
        registry["python3.14"]["version"] = "3.14.11"
        assert _iter_installed_app_issues() == [
            ("myapp", "dependency python3.14 rebuilt after this install", True)
        ]


def test_unknown_python_version_is_actionable(venv_apps: tuple[Path, dict]) -> None:
    """Missing interpreter metadata cannot silently hide an alias change."""
    opt, registry = venv_apps
    info_path = opt / "myapp" / ".install" / "info.json"
    info = json.loads(info_path.read_text())
    info["dep_versions"] = {}
    info_path.write_text(json.dumps(info))
    with (
        patch("koopa.check.opt_prefix", return_value=str(opt)),
        patch("koopa.check.import_app_json", return_value=registry),
        patch("koopa.check.installed_apps", return_value=["myapp"]),
        patch("koopa.system.os_id", return_value="macos-arm64"),
    ):
        assert _iter_installed_app_issues() == [
            ("myapp", "dependency python3.14 version unknown", True)
        ]


def test_non_python_trigger_still_rebuilds_venv(venv_apps: tuple[Path, dict]) -> None:
    """A compatible Python edge cannot hide a separate stale dependency."""
    opt, registry = venv_apps
    info_path = opt / "myapp" / ".install" / "info.json"
    info = json.loads(info_path.read_text())
    info["dependencies"].append("libffi")
    info_path.write_text(json.dumps(info))
    with (
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt)),
        patch("koopa.app.import_app_json", return_value=registry),
        patch("koopa.app.installed_apps", return_value=["python3.14", "myapp"]),
    ):
        assert stale_revdep_closure(["libffi"]) == {
            "python3.14": ["libffi"],
            "myapp": ["libffi"],
        }


def test_obsolete_cached_reason_only(venv_apps: tuple[Path, dict]) -> None:
    """Discard only automatic reasons made obsolete by a compatible venv."""
    _, registry = venv_apps
    assert _obsolete_python_venv_rebuild(
        "myapp", "resumed: dependency python3.14 rebuilt", registry
    )
    assert _obsolete_python_venv_rebuild("myapp", "dependency python rebuilt", registry)
    assert not _obsolete_python_venv_rebuild("myapp", "rebuild all", registry)
    assert not _obsolete_python_venv_rebuild(
        "myapp", "dependencies python3.14, libffi rebuilt", registry
    )


def test_update_drops_obsolete_cached_venv_rebuild(venv_apps: tuple[Path, dict]) -> None:
    """A resumed automatic plan does not reintroduce a safe-to-preserve app."""
    _, registry = venv_apps
    with (
        patch("koopa.install.is_owner", return_value=True),
        patch("koopa.check.outdated_apps_with_reasons", return_value=[]),
        patch("koopa.check.broken_app_installs", return_value=[]),
        patch("koopa.install._apps_with_missing_runtime_deps", return_value=[]),
        patch("koopa.app.shared_apps", return_value=[]),
        patch(
            "koopa.install._load_pending_plan",
            return_value=[("myapp", "dependency python rebuilt")],
        ),
        patch("koopa.app.installed_apps", return_value=["myapp"]),
        patch("koopa.io.import_app_json", return_value=registry),
        patch("koopa.install._is_supported_app", return_value=True),
        patch("koopa.install._run_install_plan") as run,
    ):
        update_stale_apps()
    run.assert_not_called()


def test_explicit_reverse_dependencies_are_still_reinstalled() -> None:
    """Explicit reverse-dependency requests bypass automatic preservation."""
    from koopa.cli_main import _reinstall_with_revdeps

    with (
        patch("koopa.app.app_revdeps", return_value=["myapp"]),
        patch("koopa.cli_main._build_install_config") as config,
        patch("koopa.install.install_app") as install,
        patch("koopa.install._remove_from_pending_plan"),
    ):
        _reinstall_with_revdeps(["python3.14"], mode="only")
    config.assert_called_once_with("myapp", reinstall=True, verbose=False)
    install.assert_called_once_with(config.return_value)


@pytest.mark.parametrize("native", [False, True])
def test_real_venv_survives_same_version_interpreter_replacement(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, native: bool
) -> None:
    """Run isolated pure and native environments across a stable opt-link replacement."""
    import _json

    version = ".".join(str(part) for part in sys.version_info[:3])
    dep = f"python{sys.version_info.major}.{sys.version_info.minor}"
    opt = tmp_path / "opt"
    opt.mkdir()
    targets = [tmp_path / slot / dep / version for slot in ("old", "new")]
    for target in targets:
        (target / "bin").mkdir(parents=True)
        (target / "bin" / dep).symlink_to(sys.executable)
    (opt / dep).symlink_to(targets[0])
    app = tmp_path / "apps" / "example" / "1.0"
    (app / ".install").mkdir(parents=True)
    (app / ".install" / "info.json").write_text(
        json.dumps({"dep_versions": {dep: version}, "dep_revisions": {}})
    )
    (opt / "example").symlink_to(app)
    venv = app / "libexec"
    subprocess.run(
        [str(opt / dep / "bin" / dep), "-m", "venv", "--without-pip", str(venv)], check=True
    )
    site_packages = venv / "lib" / dep / "site-packages"
    (site_packages / "example.py").write_text("value = 42\n")
    if native:
        assert _json.__file__ is not None
        shutil.copy2(_json.__file__, site_packages)
    monkeypatch.setattr("koopa.venv_rebuild.opt_prefix", lambda: str(opt))
    monkeypatch.setattr("koopa.venv_rebuild.os_id", lambda: "macos-arm64")
    registry = {"example": {"installer": "python-package"}, dep: {"version": version}}
    interpreter = venv / "bin" / dep
    code = (
        "import sys; sys.path.insert(0, sys.argv[1]);"
        " import example, _json; assert example.value == 42"
    )
    if native:
        code += "; assert _json.__file__.startswith(sys.argv[1])"
    for target in targets:
        (opt / dep).unlink()
        (opt / dep).symlink_to(target)
        subprocess.run(
            [str(interpreter), "-c", code, str(site_packages)],
            check=True,
        )
        assert can_preserve_python_venv("example", dep, registry) is not native
