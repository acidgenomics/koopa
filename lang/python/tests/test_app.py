"""App module unit tests."""

import shutil
import stat
from pathlib import Path
from typing import Protocol
from unittest.mock import patch

import pytest
from koopa.app import (
    _PRUNE_TRASH_PREFIX,
    app_deps,
    default_app_closure,
    default_apps,
    installer_artifact_key,
    is_cpu_bound_app,
    prune_apps,
    recorded_app_deps,
    stale_revdep_closure,
    stale_revdeps,
    stale_revdeps_with_triggers,
)


def test_app_deps_coreutils_excludes_attr_on_macos() -> None:
    """Test that 'attr' is excluded from coreutils deps on macOS."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("coreutils")
    assert "attr" not in deps


def test_app_deps_no_self_dependency_curl() -> None:
    """Test that curl does not appear in its own dependency list."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("curl")
    assert "curl" not in deps


def test_app_deps_no_self_dependency_cmake() -> None:
    """Test that cmake does not appear in its own dependency list."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("cmake")
    assert "cmake" not in deps


def test_app_deps_libarchive_includes_cmake() -> None:
    """Test that cmake is a transitive dependency of libarchive (via zstd)."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("libarchive")
    assert "cmake" in deps


def test_app_deps_tmux_includes_jemalloc_on_macos() -> None:
    """Test that jemalloc is a dependency of tmux on macOS."""
    with patch("koopa.app.os_id", return_value="macos-arm64"):
        deps = app_deps("tmux")
    assert "jemalloc" in deps


def test_app_deps_tmux_excludes_jemalloc_on_linux() -> None:
    """Test that jemalloc is not a dependency of tmux on Linux."""
    with patch("koopa.app.os_id", return_value="linux-amd64"):
        deps = app_deps("tmux")
    assert "jemalloc" not in deps


def test_default_app_closure_uses_registry_defaults_and_resolves_aliases() -> None:
    """Only supported registry defaults and their resolved dependencies are retained."""
    json_data = {
        "default-app": {"default": True, "dependencies": ["build-tool"]},
        "build-tool": {"dependencies": ["generic-python"]},
        "generic-python": {"alias_of": "python3.14"},
        "python3.14": {},
        "non-default": {"default": False},
        "unsupported": {"default": True, "supported": {"macos-arm64": False}},
        "removed": {"default": True, "removed": True},
    }
    with (
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.app.os_id", return_value="macos-arm64"),
    ):
        assert default_apps() == ["default-app"]
        assert default_app_closure() == {"build-tool", "default-app", "python3.14"}


# -- installer_artifact_key tests ---------------------------------------------


def test_installer_artifact_key_expands_version_template() -> None:
    """Test that the '{version}' placeholder is expanded."""
    json_data = {"cellranger": {"installer_artifact": "installers/cellranger/{version}.tar.xz"}}
    with patch("koopa.app.import_app_json", return_value=json_data):
        key = installer_artifact_key("cellranger", "10.0.0")
    assert key == "installers/cellranger/10.0.0.tar.xz"


def test_installer_artifact_key_returns_none_when_field_absent() -> None:
    """Test that apps without 'installer_artifact' resolve to None."""
    json_data = {"ripgrep": {"version": "14.1.0"}}
    with patch("koopa.app.import_app_json", return_value=json_data):
        key = installer_artifact_key("ripgrep", "14.1.0")
    assert key is None


def test_installer_artifact_key_returns_none_for_unknown_app() -> None:
    """Test that an app missing from app.json resolves to None."""
    with patch("koopa.app.import_app_json", return_value={}):
        key = installer_artifact_key("nonexistent", "1.0.0")
    assert key is None


# -- is_cpu_bound_app classifier tests ----------------------------------------


def _json(installer: str = "", src_url: str = "") -> dict:
    entry: dict = {}
    if installer:
        entry["installer"] = installer
    if src_url:
        entry["src_url"] = src_url
    return entry


def test_is_cpu_bound_conda_package() -> None:
    """Conda-package installer is IO-bound."""
    assert is_cpu_bound_app("aws-cli", {"aws-cli": _json("conda-package")}) is False


def test_is_cpu_bound_python_package() -> None:
    """Python-package installer is IO-bound."""
    assert is_cpu_bound_app("tqdm", {"tqdm": _json("python-package")}) is False


def test_is_cpu_bound_node_package() -> None:
    """Node-package installer is IO-bound."""
    assert is_cpu_bound_app("pyright", {"pyright": _json("node-package")}) is False


def test_is_cpu_bound_gnu_app() -> None:
    """GNU-app installer is CPU-bound."""
    assert is_cpu_bound_app("coreutils", {"coreutils": _json("gnu-app")}) is True


def test_is_cpu_bound_rust_package() -> None:
    """Rust-package installer is CPU-bound."""
    assert is_cpu_bound_app("ripgrep", {"ripgrep": _json("rust-package")}) is True


def test_is_cpu_bound_openssl_installer() -> None:
    """OpenSSL installer is CPU-bound."""
    assert is_cpu_bound_app("openssl3", {"openssl3": _json("openssl")}) is True


def test_is_cpu_bound_src_url() -> None:
    """Apps with a src_url (source builds) are CPU-bound."""
    assert (
        is_cpu_bound_app("myapp", {"myapp": _json(src_url="https://example.com/myapp.tar.gz")})
        is True
    )


def test_is_cpu_bound_download_only_allowlist_go() -> None:
    """Go is in the download-only allowlist and is IO-bound."""
    assert is_cpu_bound_app("go", {"go": _json()}) is False


def test_is_cpu_bound_download_only_allowlist_rust() -> None:
    """Rust is in the download-only allowlist and is IO-bound."""
    assert is_cpu_bound_app("rust", {"rust": _json()}) is False


def test_is_cpu_bound_ambiguous_defaults_cpu() -> None:
    """Unknown apps with no installer or src_url default to CPU-bound."""
    assert is_cpu_bound_app("unknown-custom-app", {"unknown-custom-app": _json()}) is True


def test_is_cpu_bound_missing_entry() -> None:
    """Apps absent from app.json are not classified as CPU-bound."""
    assert is_cpu_bound_app("nonexistent", {}) is False


# -- prune_apps tests ---------------------------------------------------------


def _setup_prune_tree(tmp_path: Path, name: str, linked_ver: str, stale_ver: str) -> tuple:
    """Build a minimal app+opt tree and return (app_dir, opt_dir)."""
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    linked = app_dir / name / linked_ver
    stale = app_dir / name / stale_ver
    linked.mkdir(parents=True)
    stale.mkdir(parents=True)
    opt_dir.mkdir()
    (opt_dir / name).symlink_to(linked)
    return str(app_dir), str(opt_dir)


def _cli_json(name: str) -> dict:
    return {name: {"type": "cli", "version": "current"}}


class _PatchController(Protocol):
    def start(self) -> object:
        pass

    def stop(self) -> None:
        pass


def _patch_prune(
    app_dir: str,
    opt_dir: str,
    json_data: dict,
    installed: list,
) -> list[_PatchController]:
    return [
        patch("koopa.app.koopa_app_prefix", return_value=app_dir),
        patch("koopa.app.koopa_opt_prefix", return_value=opt_dir),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.app.installed_apps", return_value=installed),
        patch("koopa.install._acquire_install_lock", return_value=False),
        patch("koopa.install._app_json_version", return_value="1.0"),
    ]


def test_prune_apps_removes_stale_keeps_linked(tmp_path: Path) -> None:
    """Stale version dir is removed; linked version dir is kept."""
    app_dir, opt_dir = _setup_prune_tree(tmp_path, "myapp", "1.1", "1.0")
    json_data = {"myapp": {"type": "cli", "version": "1.1"}}
    patches = _patch_prune(str(app_dir), str(opt_dir), json_data, ["myapp"])
    for p in patches:
        p.start()
    try:
        prune_apps()
    finally:
        for p in patches:
            p.stop()
    assert (Path(app_dir) / "myapp" / "1.1").exists()
    assert not (Path(app_dir) / "myapp" / "1.0").exists()
    remaining = list((Path(app_dir) / "myapp").iterdir())
    assert not any(r.name.startswith(_PRUNE_TRASH_PREFIX) for r in remaining)


def test_prune_apps_resilient_to_undeletable_subdir(tmp_path: Path) -> None:
    """prune_apps() does not raise even when rmtree encounters a locked subdir."""
    app_dir, opt_dir = _setup_prune_tree(tmp_path, "myapp", "1.1", "1.0")
    app_dir_path = Path(app_dir)
    app_root = app_dir_path / "myapp"
    locked = app_root / "1.0" / "locked"
    locked.mkdir()
    locked.chmod(0o000)
    json_data = {"myapp": {"type": "cli", "version": "1.1"}}
    patches = _patch_prune(str(app_dir), str(opt_dir), json_data, ["myapp"])
    for p in patches:
        p.start()
    try:
        prune_apps()
    finally:
        for p in patches:
            p.stop()
        # prune_apps may atomically move the stale version into a trash path,
        # so unlock any migrated "locked" dir to let pytest clean tmp dirs.
        for candidate in app_root.glob(f"{_PRUNE_TRASH_PREFIX}*/locked"):
            candidate.chmod(stat.S_IRWXU)
        if locked.exists():
            locked.chmod(stat.S_IRWXU)
    # The stale version must no longer be visible under the live namespace.
    assert not (Path(app_dir) / "myapp" / "1.0").exists()
    remaining = list((Path(app_dir) / "myapp").iterdir())
    assert not any(r.name.startswith(_PRUNE_TRASH_PREFIX) for r in remaining)


def test_prune_apps_sweeps_leftover_trash(tmp_path: Path) -> None:
    """Leftover trash dirs from a prior interrupted run are deleted without counting as versions."""
    app_dir_str, opt_dir_str = _setup_prune_tree(tmp_path, "myapp", "1.1", "1.0")
    # Remove the stale dir so only the leftover trash is present alongside the linked version.
    stale = Path(app_dir_str) / "myapp" / "1.0"
    stale.rmdir()
    app_dir = Path(app_dir_str)
    leftover = app_dir / "myapp" / f"{_PRUNE_TRASH_PREFIX}oldhash.99"
    leftover.mkdir()
    (leftover / "file.txt").write_text("x")
    json_data = {"myapp": {"type": "cli", "version": "1.1"}}
    patches = _patch_prune(str(app_dir), opt_dir_str, json_data, ["myapp"])
    for p in patches:
        p.start()
    try:
        prune_apps()
    finally:
        for p in patches:
            p.stop()
    assert not leftover.exists()
    remaining = list((Path(app_dir) / "myapp").iterdir())
    assert not any(r.name.startswith(_PRUNE_TRASH_PREFIX) for r in remaining)


needs_rg = pytest.mark.skipif(shutil.which("rg") is None, reason="needs ripgrep (rg)")


def _version(app_dir: Path, name: str, version: str, files: dict[str, str] | None = None) -> Path:
    """Create app/<name>/<version> with *files* (relative path to text)."""
    path = app_dir / name / version
    path.mkdir(parents=True)
    for rel, text in (files or {}).items():
        (path / rel).parent.mkdir(parents=True, exist_ok=True)
        (path / rel).write_text(text)
    return path


def _run_prune(tmp_path: Path, json_data: dict, *, dry_run: bool = False) -> None:
    """Run prune_apps over tmp_path/app and tmp_path/opt."""
    app_dir = tmp_path / "app"
    installed = sorted(p.name for p in app_dir.iterdir())
    patches = _patch_prune(str(app_dir), str(tmp_path / "opt"), json_data, installed)
    for p in patches:
        p.start()
    try:
        prune_apps(dry_run=dry_run)
    finally:
        for p in patches:
            p.stop()


def _link(tmp_path: Path, name: str, version_dir: Path) -> None:
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir(exist_ok=True)
    (opt_dir / name).symlink_to(version_dir)


@needs_rg
def test_prune_apps_prunes_unreferenced_build_tool(tmp_path: Path) -> None:
    """An old build_tool version that nothing refers to is pruned."""
    app_dir = tmp_path / "app"
    _link(tmp_path, "git", _version(app_dir, "git", "2.55.0"))
    stale = _version(app_dir, "git", "2.54.0")
    _run_prune(tmp_path, {"git": {"type": "build_tool"}})
    assert not stale.exists()
    assert (app_dir / "git" / "2.55.0").exists()


@needs_rg
def test_prune_apps_keeps_library_a_transitive_revdep_uses(tmp_path: Path) -> None:
    """An old library a kept install still loads is kept; an unused one is pruned.

    libxslt depends on zlib only through libxml2, so the scan must follow
    reverse dependencies transitively to find the reference.
    """
    app_dir = tmp_path / "app"
    zlib_old = _version(app_dir, "zlib", "1.3.2")
    zlib_older = _version(app_dir, "zlib", "1.3.1")
    _link(tmp_path, "zlib", _version(app_dir, "zlib", "1.4"))
    _link(tmp_path, "libxml2", _version(app_dir, "libxml2", "2.15.4"))
    _link(
        tmp_path,
        "libxslt",
        _version(
            app_dir, "libxslt", "1.1.45", {"bin/xsltproc": f"\0{zlib_old}/lib/libz.1.dylib\0"}
        ),
    )
    json_data = {
        "zlib": {},
        "libxml2": {"dependencies": ["zlib"]},
        "libxslt": {"dependencies": ["libxml2"]},
    }
    with patch("koopa.app._rebuild_prune_references", return_value=False):
        _run_prune(tmp_path, json_data)
    assert zlib_old.exists()
    assert not zlib_older.exists()


@needs_rg
def test_prune_apps_ignores_install_logs_and_longer_versions(tmp_path: Path) -> None:
    """A path in .install/ or a longer version (1.1 vs 1.10) is not a reference."""
    app_dir = tmp_path / "app"
    old = _version(app_dir, "dep", "1.1")
    _version(app_dir, "dep", "1.10")
    files = {
        ".install/build.log": f"PATH={old}/bin",
        "lib/libuser.dylib": f"\0{app_dir}/dep/1.10/lib\0",
    }
    _link(tmp_path, "dep", app_dir / "dep" / "1.10")
    _link(tmp_path, "user", _version(app_dir, "user", "1.0", files))
    _run_prune(tmp_path, {"dep": {}, "user": {"dependencies": ["dep"]}})
    assert not old.exists()


@needs_rg
def test_prune_apps_keeps_what_a_kept_old_version_uses(tmp_path: Path) -> None:
    """A kept old version stays installed, so the old versions it uses stay too."""
    app_dir = tmp_path / "app"
    zlib_old = _version(app_dir, "zlib", "1.3.2")
    _link(tmp_path, "zlib", _version(app_dir, "zlib", "1.4"))
    xml_old = _version(app_dir, "libxml2", "2.15.3", {"lib/libxml2.dylib": f"\0{zlib_old}/lib\0"})
    _link(tmp_path, "libxml2", _version(app_dir, "libxml2", "2.15.4"))
    files = {"bin/xsltproc": f"\0{xml_old}/lib\0"}
    _link(tmp_path, "libxslt", _version(app_dir, "libxslt", "1.1.45", files))
    json_data = {
        "zlib": {},
        "libxml2": {"dependencies": ["zlib"]},
        "libxslt": {"dependencies": ["libxml2"]},
    }
    with patch("koopa.app._rebuild_prune_references", return_value=False):
        _run_prune(tmp_path, json_data)
    assert xml_old.exists()
    assert zlib_old.exists()


@needs_rg
def test_prune_apps_rebuilds_all_referring_apps_and_rescans(tmp_path: Path) -> None:
    """Rebuild every linked owner once, then remove the unreferenced version."""
    from koopa.install import InstallConfig

    app_dir = tmp_path / "app"
    old = _version(app_dir, "go", "1.0")
    _link(tmp_path, "go", _version(app_dir, "go", "1.1"))
    for name in ("first", "second"):
        _link(tmp_path, name, _version(app_dir, name, "1.0", {"bin/tool": str(old)}))
    data = {
        "go": {"type": "build_tool"},
        "first": {"build_dependencies": ["go"]},
        "second": {"build_dependencies": ["go"]},
    }
    rebuilt: list[str] = []

    def install(config: InstallConfig) -> None:
        assert not config.binary
        assert not config.push
        rebuilt.append(config.name)
        tool = app_dir / config.name / "1.0" / "bin" / "tool"
        tool.parent.mkdir(parents=True)
        tool.write_text("rebuilt")

    with (
        patch(
            "koopa.cli_main._build_install_config",
            side_effect=lambda name, **_: InstallConfig(name),
        ),
        patch("koopa.install.install_app", side_effect=install),
    ):
        _run_prune(tmp_path, data)
    assert sorted(rebuilt) == ["first", "second"]
    assert not old.exists()


@needs_rg
def test_prune_apps_keeps_remaining_reference_after_rebuild(tmp_path: Path) -> None:
    """A rebuild that does not remove a reference must not prune its target."""
    from koopa.install import InstallConfig

    app_dir = tmp_path / "app"
    old = _version(app_dir, "go", "1.0")
    _link(tmp_path, "go", _version(app_dir, "go", "1.1"))
    _link(tmp_path, "user", _version(app_dir, "user", "1.0", {"bin/tool": str(old)}))
    data = {"go": {}, "user": {"build_dependencies": ["go"]}}

    def install(_config: InstallConfig) -> None:
        tool = app_dir / "user" / "1.0" / "bin" / "tool"
        tool.parent.mkdir(parents=True)
        tool.write_text(str(old))

    with (
        patch("koopa.cli_main._build_install_config", return_value=InstallConfig("user")),
        patch("koopa.install.install_app", side_effect=install) as install_mock,
    ):
        _run_prune(tmp_path, data)
    install_mock.assert_called_once()
    assert old.exists()


@needs_rg
def test_prune_apps_failed_rebuild_does_not_prune(tmp_path: Path) -> None:
    """An unsuccessful rebuild stops pruning before old versions are removed."""
    from koopa.install import InstallConfig

    app_dir = tmp_path / "app"
    old = _version(app_dir, "go", "1.0")
    _link(tmp_path, "go", _version(app_dir, "go", "1.1"))
    _link(tmp_path, "user", _version(app_dir, "user", "1.0", {"bin/tool": str(old)}))
    data = {"go": {}, "user": {"build_dependencies": ["go"]}}
    with (
        patch("koopa.cli_main._build_install_config", return_value=InstallConfig("user")),
        patch("koopa.install.install_app", side_effect=RuntimeError("build failed")),
        pytest.raises(RuntimeError, match="build failed"),
    ):
        _run_prune(tmp_path, data)
    assert old.exists()
    assert (app_dir / "user" / "1.0" / "bin" / "tool").read_text() == str(old)


@needs_rg
def test_prune_apps_does_not_rebuild_noncurrent_install(tmp_path: Path) -> None:
    """Do not silently replace an older linked installation with the registry version."""
    app_dir = tmp_path / "app"
    old = _version(app_dir, "go", "1.0")
    _link(tmp_path, "go", _version(app_dir, "go", "1.1"))
    _link(tmp_path, "user", _version(app_dir, "user", "0.9", {"bin/tool": str(old)}))
    with patch("koopa.install.install_app") as install:
        _run_prune(tmp_path, {"go": {}, "user": {"build_dependencies": ["go"]}})
    install.assert_not_called()
    assert old.exists()


def test_prune_apps_preserves_interrupted_rebuild(tmp_path: Path) -> None:
    """A leftover rebuild backup must not be mistaken for an old app version."""
    app_dir = tmp_path / "app"
    _link(tmp_path, "user", _version(app_dir, "user", "1.0"))
    backup = _version(app_dir, "user", ".koopa-rebuild-test", {"previous/bin/tool": "original"})
    with pytest.raises(RuntimeError, match="requires recovery"):
        _run_prune(tmp_path, {"user": {}})
    assert (backup / "previous" / "bin" / "tool").read_text() == "original"


@needs_rg
def test_prune_apps_dry_run_reports_rebuild_without_installing(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """Dry runs report affected apps without attempting a rebuild."""
    app_dir = tmp_path / "app"
    old = _version(app_dir, "go", "1.0")
    _link(tmp_path, "go", _version(app_dir, "go", "1.1"))
    _link(tmp_path, "user", _version(app_dir, "user", "1.0", {"bin/tool": str(old)}))
    with patch("koopa.install.install_app") as install:
        _run_prune(tmp_path, {"go": {}, "user": {"build_dependencies": ["go"]}}, dry_run=True)
    install.assert_not_called()
    assert old.exists()
    assert "[dry-run] Rebuilding 'user'" in capsys.readouterr().out


@needs_rg
def test_prune_apps_relinks_or_removes_stale_links(tmp_path: Path) -> None:
    """A link into a pruned version moves to the linked version, or goes away."""
    app_dir = tmp_path / "app"
    old = _version(app_dir, "libtool", "2.5.4", {"bin/libtool": "", "bin/aclocal-1.18": ""})
    new = _version(app_dir, "libtool", "2.6.2", {"bin/libtool": ""})
    _link(tmp_path, "libtool", new)
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    (bin_dir / "libtool").symlink_to(old / "bin" / "libtool")
    (bin_dir / "aclocal-1.18").symlink_to(old / "bin" / "aclocal-1.18")
    _run_prune(tmp_path, {"libtool": {"type": "build_tool"}})
    assert not old.exists()
    assert (bin_dir / "libtool").readlink() == new / "bin" / "libtool"
    assert not (bin_dir / "aclocal-1.18").is_symlink()


@needs_rg
def test_prune_apps_dry_run_changes_nothing(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A dry run reports the prune and the relink but changes no file or link."""
    app_dir = tmp_path / "app"
    old = _version(app_dir, "libtool", "2.5.4", {"bin/libtool": ""})
    new = _version(app_dir, "libtool", "2.6.2", {"bin/libtool": ""})
    _link(tmp_path, "libtool", new)
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    (bin_dir / "libtool").symlink_to(old / "bin" / "libtool")
    _run_prune(tmp_path, {"libtool": {"type": "build_tool"}}, dry_run=True)
    out = capsys.readouterr().out
    assert old.exists()
    assert (bin_dir / "libtool").readlink() == old / "bin" / "libtool"
    assert f"[dry-run] Pruning {str(old)!r}." in out
    assert "[dry-run] Relinking" in out


def test_prune_apps_without_ripgrep_keeps_versions(tmp_path: Path) -> None:
    """Without ripgrep, even CLI apps may be referenced and must be kept."""
    app_dir = tmp_path / "app"
    _link(tmp_path, "git", _version(app_dir, "git", "2.55.0"))
    git_old = _version(app_dir, "git", "2.54.0")
    _link(tmp_path, "jq", _version(app_dir, "jq", "1.8"))
    jq_old = _version(app_dir, "jq", "1.7")
    with patch("koopa.app.which", return_value=None):
        _run_prune(tmp_path, {"git": {"type": "build_tool"}, "jq": {"type": "cli"}})
    assert git_old.exists()
    assert jq_old.exists()


def _link_app_with_recorded_deps(app_dir: Path, opt_dir: Path, name: str, deps: list) -> None:
    """Link app/<name>/current under opt/, recording *deps* in .install/info.json."""
    import json

    version_dir = app_dir / name / "current"
    version_dir.mkdir(parents=True)
    (opt_dir / name).symlink_to(version_dir)
    install_dir = version_dir / ".install"
    install_dir.mkdir()
    (install_dir / "info.json").write_text(json.dumps({"dependencies": deps}))


def test_recorded_app_deps_returns_recorded_list(tmp_path: Path) -> None:
    """recorded_app_deps reads the dep list actually resolved at install time."""
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    _link_app_with_recorded_deps(app_dir, opt_dir, "python3.13", ["libffi"])
    with patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)):
        assert recorded_app_deps("python3.13") == ["libffi"]


def test_recorded_app_deps_none_when_not_linked(tmp_path: Path) -> None:
    """recorded_app_deps returns None (not []) when there is nothing to read."""
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    with patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)):
        assert recorded_app_deps("nonexistent") is None


def test_stale_revdeps_excludes_app_recorded_with_no_such_dep(tmp_path: Path) -> None:
    """A dict-typed dep that re-resolves differently now doesn't drag in a non-dependent.

    Regression test: python3.13 declares a firewall_linux/firewall_macos/default
    dependency dict. Installed under a plain shell it recorded an empty dep list;
    re-checking `stale_revdeps(["libffi"])` from a builder/firewall shell must not
    re-resolve that dict to the firewall branch and drag python3.13 in as a
    reverse dependency it was never actually built against.
    """
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    _link_app_with_recorded_deps(app_dir, opt_dir, "python3.13", [])
    _link_app_with_recorded_deps(app_dir, opt_dir, "ruby", ["libffi"])
    json_data = {
        "python3.13": {
            "version": "current",
            "dependencies": {
                "default": [],
                "firewall_linux": ["libffi"],
                "firewall_macos": ["libffi"],
            },
        },
        "ruby": {"version": "current", "dependencies": ["libffi"]},
        "libffi": {"version": "current"},
    }
    with (
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.app.installed_apps", return_value=["python3.13", "ruby"]),
    ):
        result = stale_revdeps(["libffi"])
    assert "python3.13" not in result
    assert "ruby" in result


def test_stale_revdeps_with_triggers_reports_rebuilt_dependencies(tmp_path: Path) -> None:
    """Reverse dependency rebuilds identify all direct triggering dependencies."""
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    _link_app_with_recorded_deps(app_dir, opt_dir, "dependent", ["first", "second"])
    json_data = {
        "dependent": {"version": "current", "dependencies": ["first", "second"]},
        "first": {"version": "current"},
        "second": {"version": "current"},
    }
    with (
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.app.installed_apps", return_value=["dependent"]),
    ):
        result = stale_revdeps_with_triggers(["first", "second"])
    assert result == {"dependent": ["first", "second"]}


def _patch_revdep_chain(tmp_path: Path) -> list[_PatchController]:
    """Install zlib -> libxml2 -> libxslt, each recording its direct dependency."""
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    _link_app_with_recorded_deps(app_dir, opt_dir, "zlib", [])
    _link_app_with_recorded_deps(app_dir, opt_dir, "libxml2", ["zlib"])
    _link_app_with_recorded_deps(app_dir, opt_dir, "libxslt", ["libxml2"])
    json_data = {
        "zlib": {"version": "current"},
        "libxml2": {"version": "current", "dependencies": ["zlib"]},
        "libxslt": {"version": "current", "dependencies": ["libxml2"]},
    }
    return [
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.app.installed_apps", return_value=["zlib", "libxml2", "libxslt"]),
    ]


def test_stale_revdep_closure_follows_every_level(tmp_path: Path) -> None:
    """A zlib rebuild makes libxml2 stale, and that rebuild makes libxslt stale."""
    patches = _patch_revdep_chain(tmp_path)
    for p in patches:
        p.start()
    try:
        result = stale_revdep_closure(["zlib"])
    finally:
        for p in patches:
            p.stop()
    assert result == {"libxml2": ["zlib"], "libxslt": ["libxml2"]}


def test_stale_revdep_closure_does_not_follow_a_rejected_app(tmp_path: Path) -> None:
    """An app the filter rejects is left out, and so are its reverse dependencies."""
    patches = _patch_revdep_chain(tmp_path)
    for p in patches:
        p.start()
    try:
        result = stale_revdep_closure(["zlib"], include=lambda name: name != "libxml2")
    finally:
        for p in patches:
            p.stop()
    assert result == {}
