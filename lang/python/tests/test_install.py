"""Install module unit tests."""

import threading
from pathlib import Path
from unittest.mock import MagicMock, patch


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


def test_apps_with_missing_runtime_deps_clean(tmp_path: Path) -> None:
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


def test_apps_with_missing_runtime_deps_missing(tmp_path: Path) -> None:
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


def test_apps_with_missing_runtime_deps_skips_removed(tmp_path: Path) -> None:
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


def test_apps_with_missing_runtime_deps_alias_resolved(tmp_path: Path) -> None:
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


# -- _run_install_plan scheduler tests ----------------------------------------
# These tests use a fake ProcessPoolExecutor backed by threads so the scheduler
# logic can be exercised without spawning real child processes.


class _FakePoolExecutor:
    """Fake ProcessPoolExecutor that runs work on a thread pool instead of processes."""

    def __init__(self, *, mp_context=None, max_workers=1):  # noqa: ANN001
        import concurrent.futures

        _ = mp_context
        self._pool = concurrent.futures.ThreadPoolExecutor(max_workers=max_workers)

    def submit(self, fn, *args, **kwargs):  # noqa: ANN001
        return self._pool.submit(fn, *args, **kwargs)

    def __enter__(self):  # noqa: ANN204
        self._pool.__enter__()
        return self

    def __exit__(self, *args):  # noqa: ANN002
        self._pool.__exit__(*args)


def _make_scheduler_config(app: str, _reason: str, *, is_binary: bool = True):  # noqa: ANN201
    """Build a mock InstallConfig for scheduler tests."""
    from koopa.install import InstallConfig

    return InstallConfig(name=app, binary=is_binary, deps=False)


def _noop_worker(config):  # noqa: ANN001, ANN201
    """Worker that succeeds immediately."""
    return config.name, 0.0, None


def _fail_worker(config):  # noqa: ANN001
    """Worker that always raises."""
    raise RuntimeError(f"injected failure: {config.name}")


def test_run_install_plan_single_app(_tmp_path: Path) -> None:
    """A single-app plan completes successfully."""
    from koopa.install import _run_install_plan

    plan = [("myapp", "update")]
    dep_map: dict = {}
    calls: list[str] = []

    def _worker(config):  # noqa: ANN001, ANN202
        calls.append(config.name)
        return config.name, 0.0, None

    with (
        patch("koopa.install.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.install.import_app_json", return_value={"myapp": {}}),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
    ):
        _run_install_plan(plan, dep_map, make_config=_make_scheduler_config)

    assert calls == ["myapp"]


def test_run_install_plan_dep_order(_tmp_path: Path) -> None:
    """A dependent app is not dispatched until its dep completes."""
    from koopa.install import _run_install_plan

    plan = [("dep", ""), ("app", "")]
    dep_map = {"app": {"dep"}}
    dispatch_order: list[str] = []
    dep_done = threading.Event()

    def _worker(config):  # noqa: ANN001, ANN202
        if config.name == "dep":
            dispatch_order.append("dep")
            dep_done.set()
            return config.name, 0.0, None
        dep_done.wait(timeout=5)
        dispatch_order.append("app")
        return config.name, 0.0, None

    with (
        patch("koopa.install.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.install.import_app_json", return_value={"dep": {}, "app": {}}),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
    ):
        _run_install_plan(plan, dep_map, make_config=_make_scheduler_config)

    assert dispatch_order.index("dep") < dispatch_order.index("app")


def test_run_install_plan_cpu_serialized() -> None:
    """At most one CPU-bound install runs at a time."""
    from koopa.install import InstallConfig, _run_install_plan

    plan = [("gcc", ""), ("llvm", "")]
    dep_map: dict = {}
    concurrent_cpu: list[int] = [0]
    max_concurrent: list[int] = [0]
    lock = threading.Lock()

    def _make(app: str, _reason: str) -> InstallConfig:
        return InstallConfig(name=app, binary=False, deps=False)

    def _worker(config):  # noqa: ANN001, ANN202
        import time

        with lock:
            concurrent_cpu[0] += 1
            max_concurrent[0] = max(max_concurrent[0], concurrent_cpu[0])
        time.sleep(0.05)
        with lock:
            concurrent_cpu[0] -= 1
        return config.name, 0.05, None

    # Both are CPU-bound (gnu-app installer)
    json_data = {"gcc": {"installer": "gnu-app"}, "llvm": {"installer": "gnu-app"}}

    with (
        patch("koopa.install.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
    ):
        _run_install_plan(plan, dep_map, make_config=_make)

    assert max_concurrent[0] == 1, f"Expected max 1 concurrent CPU build, got {max_concurrent[0]}"


def test_run_install_plan_io_parallel() -> None:
    """Up to KOOPA_INSTALL_JOBS IO-bound installs run concurrently."""
    import os

    from koopa.install import InstallConfig, _run_install_plan

    plan = [(f"app{i}", "") for i in range(4)]
    dep_map: dict = {}
    max_concurrent: list[int] = [0]
    current: list[int] = [0]
    lock = threading.Lock()

    def _make(app: str, reason: str) -> InstallConfig:
        return InstallConfig(name=app, binary=True, deps=False)

    def _worker(config):  # noqa: ANN001, ANN202
        import time

        with lock:
            current[0] += 1
            max_concurrent[0] = max(max_concurrent[0], current[0])
        time.sleep(0.05)
        with lock:
            current[0] -= 1
        return config.name, 0.05, None

    json_data = {f"app{i}": {} for i in range(4)}

    with (
        patch.dict(os.environ, {"KOOPA_INSTALL_JOBS": "4"}),
        patch("koopa.install.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.app.import_app_json", return_value=json_data),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
    ):
        _run_install_plan(plan, dep_map, make_config=_make)

    assert max_concurrent[0] > 1, "Expected parallel IO installs"


def test_run_install_plan_failure_aborts() -> None:
    """A failing app stops dispatch and raises RuntimeError."""
    import pytest

    from koopa.install import _run_install_plan

    plan = [("bad", ""), ("good", "")]
    dep_map: dict = {}

    def _worker(config):  # noqa: ANN001, ANN202
        if config.name == "bad":
            raise RuntimeError("injected")
        return config.name, 0.0, None

    with (
        patch("koopa.install.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.install.import_app_json", return_value={"bad": {}, "good": {}}),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
        patch("koopa.install.alert"),
    ):
        with pytest.raises(RuntimeError, match="app.*failed"):
            _run_install_plan(plan, dep_map, make_config=_make_scheduler_config)
