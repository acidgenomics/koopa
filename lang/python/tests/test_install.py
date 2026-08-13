"""Install module unit tests."""

from __future__ import annotations

import threading
from pathlib import Path
from types import TracebackType
from typing import TYPE_CHECKING
from unittest.mock import patch

import pytest

if TYPE_CHECKING:
    import concurrent.futures
    from collections.abc import Callable

    from koopa.install import InstallConfig


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
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
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
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
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
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
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
        patch("koopa.app.koopa_opt_prefix", return_value=str(opt_dir)),
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

    def __init__(self, *, mp_context: object = None, max_workers: int = 1) -> None:
        import concurrent.futures

        _ = mp_context
        self._pool = concurrent.futures.ThreadPoolExecutor(max_workers=max_workers)

    def submit(self, fn: Callable, *args: object, **kwargs: object) -> concurrent.futures.Future:
        """Submit a callable to the underlying thread pool."""
        return self._pool.submit(fn, *args, **kwargs)

    def __enter__(self) -> _FakePoolExecutor:
        self._pool.__enter__()
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        """Delegate to the underlying thread pool."""
        self._pool.__exit__(exc_type, exc_val, exc_tb)


def _make_scheduler_config(
    app: str,
    _reason: str,
    *,
    is_binary: bool = True,
) -> InstallConfig:
    """Build a mock InstallConfig for scheduler tests."""
    from koopa.install import InstallConfig

    return InstallConfig(name=app, binary=is_binary, deps=False)


def _noop_worker(
    config: InstallConfig,
    pid_map: dict[str, int] | None = None,
) -> tuple[str, str, float, None, None]:
    """Worker that succeeds immediately."""
    return config.name, config.version, 0.0, None, None


def _fail_worker(
    config: InstallConfig,
    pid_map: dict[str, int] | None = None,
) -> tuple[str, str, float, str, None]:
    """Worker that always returns a structured failure tuple."""
    return config.name, config.version, 0.0, f"injected failure: {config.name}", None


def test_run_install_plan_single_app() -> None:
    """A single-app plan completes successfully."""
    from koopa.install import _run_install_plan

    plan = [("myapp", "update")]
    dep_map: dict = {}
    calls: list[str] = []

    def _worker(config, pid_map=None):  # noqa: ANN001, ANN202
        calls.append(config.name)
        return config.name, config.version, 0.0, None, None

    with (
        patch("concurrent.futures.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.io.import_app_json", return_value={"myapp": {}}),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
    ):
        _run_install_plan(plan, dep_map, make_config=_make_scheduler_config)

    assert calls == ["myapp"]


def test_run_install_plan_dep_order() -> None:
    """A dependent app is not dispatched until its dep completes."""
    from koopa.install import _run_install_plan

    plan = [("dep", ""), ("app", "")]
    dep_map = {"app": {"dep"}}
    dispatch_order: list[str] = []
    dep_done = threading.Event()

    def _worker(config, pid_map=None):  # noqa: ANN001, ANN202
        if config.name == "dep":
            dispatch_order.append("dep")
            dep_done.set()
            return config.name, config.version, 0.0, None, None
        dep_done.wait(timeout=5)
        dispatch_order.append("app")
        return config.name, config.version, 0.0, None, None

    with (
        patch("concurrent.futures.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.io.import_app_json", return_value={"dep": {}, "app": {}}),
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

    def _worker(config, pid_map=None):  # noqa: ANN001, ANN202
        import time

        with lock:
            concurrent_cpu[0] += 1
            max_concurrent[0] = max(max_concurrent[0], concurrent_cpu[0])
        time.sleep(0.05)
        with lock:
            concurrent_cpu[0] -= 1
        return config.name, config.version, 0.05, None, None

    # Both are CPU-bound (gnu-app installer)
    json_data = {"gcc": {"installer": "gnu-app"}, "llvm": {"installer": "gnu-app"}}

    with (
        patch("concurrent.futures.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.io.import_app_json", return_value=json_data),
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

    def _make(app: str, _reason: str) -> InstallConfig:
        return InstallConfig(name=app, binary=True, deps=False)

    def _worker(config, pid_map=None):  # noqa: ANN001, ANN202
        import time

        with lock:
            current[0] += 1
            max_concurrent[0] = max(max_concurrent[0], current[0])
        time.sleep(0.05)
        with lock:
            current[0] -= 1
        return config.name, config.version, 0.05, None, None

    json_data = {f"app{i}": {} for i in range(4)}

    with (
        patch.dict(os.environ, {"KOOPA_INSTALL_JOBS": "4"}),
        patch("concurrent.futures.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.io.import_app_json", return_value=json_data),
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

    def _worker(config, pid_map=None):  # noqa: ANN001, ANN202
        if config.name == "bad":
            return config.name, config.version, 0.0, "injected", None
        return config.name, config.version, 0.0, None, None

    with (
        patch("concurrent.futures.ProcessPoolExecutor", _FakePoolExecutor),
        patch("koopa.install._install_app_worker", _worker),
        patch("koopa.io.import_app_json", return_value={"bad": {}, "good": {}}),
        patch("koopa.install._remove_from_pending_plan"),
        patch("koopa.install._save_pending_plan"),
        patch("koopa.alert.alert"),
        pytest.raises(RuntimeError, match=r"app.*failed"),
    ):
        _run_install_plan(plan, dep_map, make_config=_make_scheduler_config)


def test_check_platform_support_appends_unsupported_note() -> None:
    """The gate error includes the app's unsupported_note when set."""
    import pytest
    from koopa.cli_main import _check_platform_support, _os_id

    app_meta = {
        "supported": {_os_id(): False},
        "unsupported_note": "Use a Linux x86_64 host instead.",
    }

    with pytest.raises(RuntimeError, match=r"Use a Linux x86_64 host instead\."):
        _check_platform_support("illumina-ica-cli", app_meta)


def test_check_platform_support_no_note() -> None:
    """The gate error is bare when unsupported_note is absent."""
    import pytest
    from koopa.cli_main import _check_platform_support, _os_id

    app_meta = {"supported": {_os_id(): False}}

    with pytest.raises(RuntimeError) as exc_info:
        _check_platform_support("some-app", app_meta)

    assert "\n" not in str(exc_info.value)


# -- _load_pending_plan resume-validation tests -------------------------------


def _write_pending_plan(cache_path: Path, created: str) -> None:
    import json as json_mod

    cache_path.write_text(
        json_mod.dumps(
            {
                "created": created,
                "source": "update",
                "plan": [{"app": "stale-app", "reason": "outdated"}],
            },
        ),
    )


def test_load_pending_plan_drops_app_installed_after_cache(tmp_path: Path) -> None:
    """An app installed (e.g. by hand) after the plan was cached is dropped."""
    import json as json_mod
    from datetime import UTC, datetime, timedelta

    from koopa.install import _load_pending_plan

    cache_path = tmp_path / "update-plan.json"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()

    created = datetime.now(tz=UTC) - timedelta(hours=1)
    _write_pending_plan(cache_path, created.isoformat())

    info_dir = opt_dir / "stale-app" / ".install"
    info_dir.mkdir(parents=True)
    installed_at = datetime.now(tz=UTC) - timedelta(minutes=30)  # after `created`
    info_dir.joinpath("info.json").write_text(
        json_mod.dumps({"date": installed_at.strftime("%Y-%m-%d %H:%M:%S")}),
    )

    with (
        patch("koopa.install._update_plan_cache_path", return_value=str(cache_path)),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
    ):
        plan = _load_pending_plan(source="update")

    assert plan == []


def test_load_pending_plan_keeps_app_installed_before_cache(tmp_path: Path) -> None:
    """An app whose install predates the cached plan is kept for resume."""
    import json as json_mod
    from datetime import UTC, datetime, timedelta

    from koopa.install import _load_pending_plan

    cache_path = tmp_path / "update-plan.json"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()

    created = datetime.now(tz=UTC) - timedelta(hours=1)
    _write_pending_plan(cache_path, created.isoformat())

    info_dir = opt_dir / "stale-app" / ".install"
    info_dir.mkdir(parents=True)
    installed_at = datetime.now(tz=UTC) - timedelta(hours=2)  # before `created`
    info_dir.joinpath("info.json").write_text(
        json_mod.dumps({"date": installed_at.strftime("%Y-%m-%d %H:%M:%S")}),
    )

    with (
        patch("koopa.install._update_plan_cache_path", return_value=str(cache_path)),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
    ):
        plan = _load_pending_plan(source="update")

    assert plan == [("stale-app", "outdated")]


def test_load_pending_plan_keeps_app_with_no_info_json(tmp_path: Path) -> None:
    """An app not (yet) installed at all is kept for resume."""
    from datetime import UTC, datetime, timedelta

    from koopa.install import _load_pending_plan

    cache_path = tmp_path / "update-plan.json"
    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()
    # No opt/stale-app directory at all.

    created = datetime.now(tz=UTC) - timedelta(hours=1)
    _write_pending_plan(cache_path, created.isoformat())

    with (
        patch("koopa.install._update_plan_cache_path", return_value=str(cache_path)),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
    ):
        plan = _load_pending_plan(source="update")

    assert plan == [("stale-app", "outdated")]


# ── push_app_build / push_missing_app_builds ─────────────────────────────────


def _link_python_versions(tmp_path: Path) -> tuple[Path, Path, Path, Path]:
    """Build app/python3.13/{3.13.9,3.13.15} with opt/python3.13 -> 3.13.15.

    3.13.9 sorts *after* 3.13.15 as a string, so a `sorted(listdir)[-1]` version
    pick lands on the wrong (unlinked) directory.
    """
    app_dir = tmp_path / "app"
    opt_dir = tmp_path / "opt"
    linked = app_dir / "python3.13" / "3.13.15"
    older = app_dir / "python3.13" / "3.13.9"
    linked.mkdir(parents=True)
    older.mkdir(parents=True)
    opt_dir.mkdir()
    (opt_dir / "python3.13").symlink_to(linked)
    return app_dir, opt_dir, linked, older


def test_push_app_build_uses_linked_version_not_string_max(tmp_path: Path) -> None:
    """push_app_build tars the version linked under opt/, not the string-max sibling."""
    from koopa.install import push_app_build

    app_dir, opt_dir, linked, older = _link_python_versions(tmp_path)
    json_data = {"python3.13": {"version": "3.13.15"}}

    with (
        patch("koopa.install.koopa_prefix", return_value="/opt/koopa"),
        patch("koopa.install.app_prefix", return_value=str(app_dir)),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.install.arch2", return_value="arm64"),
        patch("koopa.install.os_slug", return_value="macos"),
        patch("koopa.install.import_app_json", return_value=json_data),
        patch("koopa.aws.koopa_s3_bucket", return_value="artifacts-bucket"),
        patch("koopa.vendor.vendor_config", return_value=None),
        patch("koopa.install.run") as mock_run,
    ):
        push_app_build("python3.13")

    tar_args = mock_run.call_args_list[0].args
    assert tar_args[-1] == str(linked)
    assert str(older) not in tar_args

    cp_args = mock_run.call_args_list[1].args
    assert cp_args[-1].endswith("python3.13/3.13.15.tar.gz")


def test_push_app_build_raises_when_not_linked(tmp_path: Path) -> None:
    """push_app_build refuses to guess a version when opt/<name> isn't linked."""
    from koopa.install import push_app_build

    opt_dir = tmp_path / "opt"
    opt_dir.mkdir()

    with (
        patch("koopa.install.koopa_prefix", return_value="/opt/koopa"),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        pytest.raises(FileNotFoundError),
    ):
        push_app_build("python3.13")


def test_push_missing_app_builds_checks_linked_version(tmp_path: Path) -> None:
    """push_missing_app_builds queries S3 for the linked version, not the string-max sibling."""
    from koopa.install import push_missing_app_builds

    _app_dir, opt_dir, _linked, _older = _link_python_versions(tmp_path)

    with (
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        patch("koopa.install.arch2", return_value="arm64"),
        patch("koopa.install.os_slug", return_value="macos"),
        patch("shutil.which", return_value="/usr/bin/aws"),
        patch("koopa.aws.koopa_s3_bucket", return_value="artifacts-bucket"),
        patch("koopa.aws.s3_object_exists", return_value=True) as mock_exists,
    ):
        push_missing_app_builds()

    key = mock_exists.call_args.args[1]
    assert key.endswith("python3.13/3.13.15-r1.tar.gz")
    assert "3.13.9" not in key


def test_can_push_binary_denies_private_non_builder_hosts() -> None:
    """Private acidgenomics hosts cannot push unless KOOPA_BUILDER=1."""
    from koopa.install import _can_push_binary

    with (
        patch("koopa.install.can_build_binary", return_value=False),
        patch("koopa.vendor.vendor_can_push", return_value=False),
        patch("koopa.install._has_private_access", return_value=True),
        patch("koopa.build.locate", return_value="/usr/bin/aws"),
    ):
        assert _can_push_binary() is False


def test_can_push_binary_allows_private_builder_hosts() -> None:
    """Private acidgenomics builders can push when aws CLI is available."""
    from koopa.install import _can_push_binary

    with (
        patch("koopa.install.can_build_binary", return_value=True),
        patch("koopa.install.koopa_prefix", return_value="/opt/koopa"),
        patch("koopa.vendor.vendor_can_push", return_value=False),
        patch("koopa.install._has_private_access", return_value=True),
        patch("koopa.build.locate", return_value="/usr/bin/aws"),
    ):
        assert _can_push_binary() is True


def test_can_push_binary_requires_aws_cli_for_private_path() -> None:
    """Private push path is disabled when aws CLI is unavailable."""
    from koopa.install import _can_push_binary

    with (
        patch("koopa.install.can_build_binary", return_value=False),
        patch("koopa.vendor.vendor_can_push", return_value=False),
        patch("koopa.install._has_private_access", return_value=True),
        patch("koopa.build.locate", side_effect=FileNotFoundError),
    ):
        assert _can_push_binary() is False


def test_can_push_binary_denies_non_default_prefix() -> None:
    """A builder with private access still can't push from a non-'/opt/koopa' prefix.

    Pushed tarballs record absolute paths ('tar -Pcz'), so a tarball built
    against any other prefix can never be extracted by a puller.
    """
    from koopa.install import _can_push_binary

    with (
        patch("koopa.install.can_build_binary", return_value=True),
        patch("koopa.install.koopa_prefix", return_value="/home/u/.local/share/koopa"),
        patch("koopa.vendor.vendor_can_push", return_value=False),
        patch("koopa.install._has_private_access", return_value=True),
        patch("koopa.build.locate", return_value="/usr/bin/aws"),
    ):
        assert _can_push_binary() is False


def test_push_app_build_rejects_non_default_prefix(tmp_path: Path) -> None:
    """push_app_build refuses to build a tarball outside '/opt/koopa'."""
    from koopa.install import push_app_build

    _app_dir, opt_dir, _linked, _older = _link_python_versions(tmp_path)

    with (
        patch("koopa.install.koopa_prefix", return_value="/home/u/.local/share/koopa"),
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        pytest.raises(RuntimeError, match="/opt/koopa"),
    ):
        push_app_build("python3.13")


def test_link_in_bin_replaces_non_symlink_file(tmp_path: Path) -> None:
    """A self-updater (e.g. agy) can clobber a koopa-managed link with a real file.

    Regression test: this previously raised 'FileExistsError' from 'os.symlink()'
    on the next 'koopa update', aborting the whole run.
    """
    from koopa.install import link_in_bin

    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    source = tmp_path / "app" / "agy"
    source.parent.mkdir()
    source.write_text("#!/bin/sh\n")
    target = bin_dir / "agy"
    target.write_bytes(b"not a symlink")

    with patch("koopa.install.bin_prefix", return_value=str(bin_dir)):
        link_in_bin(name="agy", source=str(source))

    assert target.is_symlink()
    assert Path(target).resolve() == source.resolve()


def test_link_in_bin_replaces_broken_symlink(tmp_path: Path) -> None:
    """A stale symlink to a removed app version is replaced, not left dangling."""
    from koopa.install import link_in_bin

    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    source = tmp_path / "app" / "tool"
    source.parent.mkdir()
    source.write_text("#!/bin/sh\n")
    target = bin_dir / "tool"
    target.symlink_to(tmp_path / "app" / "gone")

    with patch("koopa.install.bin_prefix", return_value=str(bin_dir)):
        link_in_bin(name="tool", source=str(source))

    assert target.resolve() == source.resolve()


def test_link_in_opt_refuses_to_replace_a_real_directory(tmp_path: Path) -> None:
    """A real directory at the target is never implicitly removed."""
    from koopa.install import link_in_opt

    opt_dir = tmp_path / "opt"
    source = tmp_path / "app" / "curl" / "8.0"
    source.mkdir(parents=True)
    target_dir = opt_dir / "curl"
    target_dir.mkdir(parents=True)

    with (
        patch("koopa.install.opt_prefix", return_value=str(opt_dir)),
        pytest.raises(IsADirectoryError),
    ):
        link_in_opt(name="curl", source=str(source))
