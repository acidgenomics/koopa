"""App module unit tests."""

import os
import stat
from pathlib import Path
from unittest.mock import patch

from koopa.app import _PRUNE_TRASH_PREFIX, app_deps, is_cpu_bound_app, prune_apps


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
    return {name: {"type": "cli", "version": linked_ver} for linked_ver in ["current"]}


def _patch_prune(app_dir: str, opt_dir: str, json_data: dict, installed: list):
    return [
        patch("koopa.app.koopa_app_prefix", return_value=app_dir),
        patch("koopa.app.koopa_opt_prefix", return_value=opt_dir),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.app.installed_apps", return_value=installed),
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
    locked = Path(app_dir) / "myapp" / "1.0" / "locked"
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
        if locked.exists():
            locked.chmod(stat.S_IRWXU)
    # The stale version must no longer be visible under the live namespace.
    assert not (Path(app_dir) / "myapp" / "1.0").exists()


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


def test_prune_apps_skips_non_cli_type(tmp_path: Path) -> None:
    """Apps with type != 'cli' (e.g. build_tool) are not pruned."""
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    linked = app_dir / "git" / "2.55.0"
    stale = app_dir / "git" / "2.54.0"
    linked.mkdir(parents=True)
    stale.mkdir(parents=True)
    opt_dir.mkdir()
    (opt_dir / "git").symlink_to(linked)
    json_data = {"git": {"type": "build_tool", "version": "2.55.0"}}
    patches = _patch_prune(str(app_dir), str(opt_dir), json_data, ["git"])
    for p in patches:
        p.start()
    try:
        prune_apps()
    finally:
        for p in patches:
            p.stop()
    assert stale.exists()
