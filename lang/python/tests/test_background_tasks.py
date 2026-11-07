"""Tests for koopa.background_tasks."""

import fcntl
from datetime import datetime
from pathlib import Path

import pytest
from koopa import background_tasks as bt


def _at(hour: int, minute: int = 0, day: int = 6) -> datetime:
    return datetime(2026, 11, day, hour, minute).astimezone()


# ---------------------------------------------------------------------------
# latest_schedule_boundary
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("now", "key", "mode"),
    [
        (_at(8, 59), "2026-11-05T17", "dark"),
        (_at(9, 0), "2026-11-06T09", "light"),
        (_at(12, 30), "2026-11-06T09", "light"),
        (_at(16, 59), "2026-11-06T09", "light"),
        (_at(17, 0), "2026-11-06T17", "dark"),
        (_at(23, 59), "2026-11-06T17", "dark"),
        (_at(0, 0), "2026-11-05T17", "dark"),
    ],
)
def test_latest_schedule_boundary(now: datetime, key: str, mode: str) -> None:
    """Each time maps to the most recent 09:00 or 17:00 boundary."""
    assert bt.latest_schedule_boundary(now) == (key, mode)


# ---------------------------------------------------------------------------
# schedule_color_mode
# ---------------------------------------------------------------------------


class _FakeOS:
    """Stand-in for the macOS appearance calls."""

    def __init__(self, mode: str, *, auto: bool = False) -> None:
        self.mode = mode
        self.auto = auto
        self.sets: list[str] = []

    def set_mode(self, mode: str) -> None:
        self.sets.append(mode)
        self.mode = mode


@pytest.fixture
def fake_os(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> _FakeOS:
    """Patch the OS calls and give the host a Dracula Pro data dir."""
    fake = _FakeOS("dark")
    (tmp_path / "data" / "dracula-pro").mkdir(parents=True)
    monkeypatch.setattr(bt, "is_macos", lambda: True)
    monkeypatch.setattr(bt, "xdg_data_home", lambda: str(tmp_path / "data"))
    monkeypatch.setattr(bt, "os_appearance_mode", lambda: fake.mode)
    monkeypatch.setattr(bt, "_auto_appearance_on", lambda: fake.auto)
    monkeypatch.setattr(bt, "_set_os_mode", fake.set_mode)
    return fake


def test_schedule_flips_once_per_boundary(fake_os: _FakeOS, tmp_path: Path) -> None:
    """The 09:00 boundary sets light once; later runs that day do nothing."""
    bt.schedule_color_mode(_at(9, 0), str(tmp_path))
    assert fake_os.sets == ["light"]
    bt.schedule_color_mode(_at(9, 10), str(tmp_path))
    bt.schedule_color_mode(_at(16, 50), str(tmp_path))
    assert fake_os.sets == ["light"]


def test_schedule_keeps_manual_toggle(fake_os: _FakeOS, tmp_path: Path) -> None:
    """A manual switch to dark at noon stays until the 17:00 boundary."""
    bt.schedule_color_mode(_at(9, 0), str(tmp_path))
    fake_os.mode = "dark"  # the user toggles by hand
    bt.schedule_color_mode(_at(12, 0), str(tmp_path))
    bt.schedule_color_mode(_at(12, 10), str(tmp_path))
    assert fake_os.mode == "dark"
    assert fake_os.sets == ["light"]


def test_schedule_applies_missed_boundary(fake_os: _FakeOS, tmp_path: Path) -> None:
    """A wake at 10:30 after sleeping through 09:00 still sets light."""
    bt.schedule_color_mode(_at(23, 0, day=5), str(tmp_path))  # last seen: dark
    assert fake_os.sets == []
    bt.schedule_color_mode(_at(10, 30), str(tmp_path))
    assert fake_os.sets == ["light"]


def test_schedule_records_boundary_when_mode_already_matches(
    fake_os: _FakeOS, tmp_path: Path
) -> None:
    """A boundary that needs no change is still recorded, so a later toggle stays."""
    bt.schedule_color_mode(_at(17, 0), str(tmp_path))
    assert fake_os.sets == []
    fake_os.mode = "light"
    bt.schedule_color_mode(_at(18, 0), str(tmp_path))
    assert fake_os.sets == []


def test_schedule_skips_when_auto_appearance_on(fake_os: _FakeOS, tmp_path: Path) -> None:
    """macOS's own Auto appearance wins over the schedule."""
    fake_os.auto = True
    bt.schedule_color_mode(_at(9, 0), str(tmp_path))
    assert fake_os.sets == []


def test_schedule_skips_without_dracula_pro(
    fake_os: _FakeOS, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """A host without Dracula Pro gets no schedule."""
    monkeypatch.setattr(bt, "xdg_data_home", lambda: str(tmp_path / "empty"))
    bt.schedule_color_mode(_at(9, 0), str(tmp_path))
    assert fake_os.sets == []


# ---------------------------------------------------------------------------
# organize_screenshots_task
# ---------------------------------------------------------------------------


def test_organize_screenshots_rate_limit(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """Runs at most once per minimum gap, then again after it."""
    home = tmp_path / "home"
    (home / "Pictures" / "screenshots").mkdir(parents=True)
    monkeypatch.setenv("HOME", str(home))
    calls: list[str] = []

    def fake_organize(directory: str, *, quiet: bool) -> list[str]:
        assert quiet
        calls.append(directory)
        return []

    monkeypatch.setattr("koopa.file_ops.organize_screenshots", fake_organize)
    state = str(tmp_path / "state")
    Path(state).mkdir()
    bt.organize_screenshots_task(1000.0, state)
    bt.organize_screenshots_task(1000.0 + bt._SCREENSHOTS_MIN_GAP - 1, state)
    assert len(calls) == 1
    bt.organize_screenshots_task(1000.0 + bt._SCREENSHOTS_MIN_GAP, state)
    assert len(calls) == 2


def test_organize_screenshots_skips_missing_dir(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """No screenshots folder means no run and no state file."""
    monkeypatch.setenv("HOME", str(tmp_path))
    bt.organize_screenshots_task(1000.0, str(tmp_path))
    assert not (tmp_path / "organize-screenshots").exists()


# ---------------------------------------------------------------------------
# sync_color_mode
# ---------------------------------------------------------------------------


def test_sync_color_mode_skips_when_marker_matches(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A matching applied marker means the configurer is not called."""
    marker = tmp_path / ".cache" / "koopa" / "color-mode-applied"
    marker.parent.mkdir(parents=True)
    marker.write_text("dark\n")
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr(bt, "os_appearance_mode", lambda: "dark")
    monkeypatch.setattr(
        "koopa.configurers.color_mode._sync_claude_auto_theme", lambda *_a: False
    )
    calls: list[object] = []
    monkeypatch.setattr("koopa.configure.configure_app", calls.append)
    bt.sync_color_mode()
    assert calls == []


def test_sync_color_mode_repairs_claude_theme_when_marker_matches(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """The Claude theme is synced on every run, even when nothing else changed."""
    marker = tmp_path / ".cache" / "koopa" / "color-mode-applied"
    marker.parent.mkdir(parents=True)
    marker.write_text("dark\n")
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr(bt, "os_appearance_mode", lambda: "dark")
    synced: list[tuple[str, str]] = []

    def fake_sync(mode: str, themes_dir: str) -> bool:
        synced.append((mode, themes_dir))
        return True

    monkeypatch.setattr("koopa.configurers.color_mode._sync_claude_auto_theme", fake_sync)
    monkeypatch.setattr("koopa.configure.configure_app", lambda _c: None)
    bt.sync_color_mode()
    assert synced == [("dark", str(tmp_path / ".claude" / "themes"))]


def test_sync_color_mode_runs_when_marker_differs(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    """A stale marker calls the color-mode configurer once."""
    monkeypatch.setenv("HOME", str(tmp_path))
    monkeypatch.setattr(bt, "os_appearance_mode", lambda: "light")
    monkeypatch.setattr(
        "koopa.configurers.color_mode._sync_claude_auto_theme", lambda *_a: False
    )
    calls: list[object] = []
    monkeypatch.setattr("koopa.configure.configure_app", calls.append)
    bt.sync_color_mode()
    assert len(calls) == 1
    assert getattr(calls[0], "name", None) == "color-mode"


# ---------------------------------------------------------------------------
# run_background_tasks
# ---------------------------------------------------------------------------


def test_failing_task_does_not_stop_others(tmp_path: Path) -> None:
    """A task that raises is reported, and later tasks still run."""
    ran: list[str] = []

    def boom() -> None:
        msg = "boom"
        raise RuntimeError(msg)

    failed = bt.run_background_tasks(
        tasks=[("first", boom), ("second", lambda: ran.append("second"))],
        state_dir=str(tmp_path),
    )
    assert failed == ["first"]
    assert ran == ["second"]


def test_system_exit_does_not_stop_others(tmp_path: Path) -> None:
    """A task that raises SystemExit is reported, and later tasks still run."""
    ran: list[str] = []

    def exits() -> None:
        msg = "Not a directory: '/gone'"
        raise SystemExit(msg)

    failed = bt.run_background_tasks(
        tasks=[("first", exits), ("second", lambda: ran.append("second"))],
        state_dir=str(tmp_path),
    )
    assert failed == ["first"]
    assert ran == ["second"]


def test_runs_tasks_in_order(tmp_path: Path) -> None:
    """Tasks run in the order given."""
    ran: list[str] = []
    bt.run_background_tasks(
        tasks=[("a", lambda: ran.append("a")), ("b", lambda: ran.append("b"))],
        state_dir=str(tmp_path),
    )
    assert ran == ["a", "b"]


def test_skips_when_another_run_holds_lock(tmp_path: Path) -> None:
    """A second run exits without running tasks while the lock is held."""
    ran: list[str] = []
    with open(tmp_path / "lock", "w") as fh:
        fcntl.flock(fh, fcntl.LOCK_EX)
        failed = bt.run_background_tasks(
            tasks=[("a", lambda: ran.append("a"))],
            state_dir=str(tmp_path),
        )
    assert failed == []
    assert ran == []
