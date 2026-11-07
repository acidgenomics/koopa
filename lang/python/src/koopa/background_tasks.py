"""Run koopa's background tasks from one launchd job.

The ``com.acidgenomics.koopa`` launch agent starts ``koopa run background-tasks``
on every trigger: a change to the global preferences file, a calendar time
(00:00, 09:00, 17:00), a 600-second timer, and login.  launchd does not tell
the job which trigger fired, so each task decides for itself whether to act.
This keeps a manual appearance toggle in place, and the timer recovers any
event that launchd missed.

Task order matters: the appearance schedule runs before the color-mode sync,
so a scheduled flip can be applied in the same pass.
"""

import fcntl
import os
import subprocess
import time
from collections.abc import Callable, Sequence
from datetime import datetime, timedelta

from koopa.alert import alert_info, alert_note, warn
from koopa.system import is_macos, os_appearance_mode
from koopa.text import plural
from koopa.xdg import xdg_cache_home, xdg_data_home

Task = tuple[str, Callable[[], None]]

# Appearance schedule boundaries in local time, as (hour, mode).
_SCHEDULE: tuple[tuple[int, str], ...] = ((9, "light"), (17, "dark"))

# Minimum gap between screenshot runs.  It is below the 600-second launchd
# timer, so a timer firing that arrives a moment early still runs the task.
_SCREENSHOTS_MIN_GAP = 540


def _state_dir() -> str:
    """Return the directory for background-task state files.

    Returns
    -------
    str
        Path to ``<XDG_CACHE_HOME>/koopa/background-tasks``.
    """
    return os.path.join(xdg_cache_home(), "koopa", "background-tasks")


def _log(message: str) -> None:
    """Print a timestamped message to the launch agent log.

    Parameters
    ----------
    message : str
        Message to print.
    """
    ts = datetime.now().astimezone().isoformat(timespec="seconds")
    alert_info(f"[{ts}] {message}")


def _read_state(path: str) -> str:
    """Return the stripped contents of a state file.

    Parameters
    ----------
    path : str
        Path to the state file.

    Returns
    -------
    str
        File contents without surrounding whitespace, or an empty string when
        the file does not exist.
    """
    if not os.path.isfile(path):
        return ""
    with open(path) as fh:
        return fh.read().strip()


def _write_state(path: str, value: str) -> None:
    """Write a value to a state file.

    Parameters
    ----------
    path : str
        Path to the state file.
    value : str
        Value to write.
    """
    with open(path, "w") as fh:
        fh.write(value + "\n")


def latest_schedule_boundary(now: datetime) -> tuple[str, str]:
    """Return the latest appearance schedule boundary at or before ``now``.

    Parameters
    ----------
    now : datetime
        Current local time.

    Returns
    -------
    tuple[str, str]
        The boundary key (``YYYY-MM-DDTHH``) and the mode it sets
        (``"light"`` or ``"dark"``).
    """
    candidates: list[tuple[datetime, str]] = []
    for day_offset in (0, -1):
        day = now + timedelta(days=day_offset)
        for hour, mode in _SCHEDULE:
            at = day.replace(hour=hour, minute=0, second=0, microsecond=0)
            if at <= now:
                candidates.append((at, mode))
    at, mode = max(candidates)
    return at.strftime("%Y-%m-%dT%H"), mode


def _auto_appearance_on() -> bool:
    """Return True when macOS switches appearance automatically.

    Returns
    -------
    bool
        True when ``AppleInterfaceStyleSwitchesAutomatically`` is ``1``.
    """
    try:
        result = subprocess.run(
            ["/usr/bin/defaults", "read", "-g", "AppleInterfaceStyleSwitchesAutomatically"],
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError:
        # `defaults read` exits non-zero when the key is absent: Auto is off.
        return False
    return result.stdout.strip() == "1"


def _set_os_mode(mode: str) -> None:
    """Set the macOS appearance.

    Parameters
    ----------
    mode : str
        ``"dark"`` or ``"light"``.
    """
    dark = "true" if mode == "dark" else "false"
    script = (
        'tell application "System Events" to tell appearance preferences '
        f"to set dark mode to {dark}"
    )
    # The timeout stops a pending Automation permission prompt from blocking
    # every later task in this run.
    subprocess.run(
        ["/usr/bin/osascript", "-e", script],
        capture_output=True,
        check=True,
        timeout=30,
    )


def _wait_for_os_mode(mode: str, attempts: int = 10) -> bool:
    """Wait until the OS reports the given appearance.

    macOS can report the old value for a short time after a switch.  The
    color-mode sync runs next in the same pass, so it must see the new value.

    Parameters
    ----------
    mode : str
        ``"dark"`` or ``"light"``.
    attempts : int, optional
        Number of checks, 0.5 seconds apart.

    Returns
    -------
    bool
        True when the OS reports ``mode`` within the given checks.
    """
    for _ in range(attempts):
        if os_appearance_mode() == mode:
            return True
        time.sleep(0.5)
    return False


def schedule_color_mode(now: datetime, state_dir: str) -> None:
    """Set the macOS appearance once for each schedule boundary.

    The appearance is dark before 09:00, light from 09:00 to 17:00, and dark
    after 17:00.  The task acts once per boundary and records it, so a manual
    toggle stays in place until the next boundary.  A boundary missed during
    sleep or logout is applied on the next run.  The task does nothing unless
    the host is macOS with Dracula Pro installed and macOS's own Auto
    appearance is off.

    Parameters
    ----------
    now : datetime
        Current local time.
    state_dir : str
        Directory for the state file that records the last boundary.
    """
    if not is_macos():
        return
    if not os.path.isdir(os.path.join(xdg_data_home(), "dracula-pro")):
        return
    if _auto_appearance_on():
        return
    key, mode = latest_schedule_boundary(now)
    state_file = os.path.join(state_dir, "color-mode-schedule")
    if _read_state(state_file) == key:
        return
    if os_appearance_mode() != mode:
        _set_os_mode(mode)
        _log(f"color-mode-schedule: {key}:00 -> {mode}")
        if not _wait_for_os_mode(mode):
            warn(f"color-mode-schedule: macOS does not report {mode} yet.")
    _write_state(state_file, key)


def sync_color_mode() -> None:
    """Keep the Claude theme current, and re-apply color-mode dotfiles if needed.

    The Claude auto theme is synced on every run, before the marker check, so
    a stale or missing theme file is repaired within one timer tick even when
    nothing else changed.  The dotfiles re-apply runs the same configurer as
    ``koopa configure user color-mode``, and only when the applied marker
    differs from the OS mode, so a run with nothing to do prints nothing.
    """
    from koopa.configurers.color_mode import _sync_claude_auto_theme

    home = os.path.expanduser("~")
    mode = os_appearance_mode()
    _sync_claude_auto_theme(mode, os.path.join(home, ".claude", "themes"))
    # Same marker path as configurers.color_mode.main().
    marker = os.path.join(home, ".cache", "koopa", "color-mode-applied")
    if _read_state(marker) == mode:
        return
    from koopa.configure import ConfigureConfig, configure_app

    configure_app(ConfigureConfig(name="color-mode", mode="user"))


def update_today_bucket() -> None:
    """Repoint the dated today-bucket links at today's directory.

    Runs the same code as ``koopa run update-today-bucket``, which is
    idempotent and does nothing when no bucket directory exists.
    """
    from koopa.cli_bin import _handle_update_today_bucket

    _handle_update_today_bucket([])


def organize_screenshots_task(now: float, state_dir: str) -> None:
    """Organize screenshots, at most once per 540 seconds.

    Parameters
    ----------
    now : float
        Current time in seconds since the epoch.
    state_dir : str
        Directory for the state file that records the last run.
    """
    directory = os.path.join(os.path.expanduser("~"), "Pictures", "screenshots")
    if not os.path.isdir(directory):
        return
    state_file = os.path.join(state_dir, "organize-screenshots")
    try:
        last_run = float(_read_state(state_file) or 0)
    except ValueError:
        last_run = 0.0
    if now - last_run < _SCREENSHOTS_MIN_GAP:
        return
    from koopa.file_ops import organize_screenshots

    moved = organize_screenshots(directory, quiet=True)
    _write_state(state_file, str(now))
    if moved:
        n = len(moved)
        _log(f"organize-screenshots: moved {n} {plural(n, 'file')}")


def _default_tasks(state_dir: str) -> list[Task]:
    """Return the standard tasks, in run order.

    Parameters
    ----------
    state_dir : str
        Directory for task state files.

    Returns
    -------
    list[Task]
        ``(name, callable)`` pairs.
    """
    return [
        (
            "color-mode-schedule",
            lambda: schedule_color_mode(datetime.now().astimezone(), state_dir),
        ),
        ("color-mode-sync", sync_color_mode),
        ("today-bucket", update_today_bucket),
        ("organize-screenshots", lambda: organize_screenshots_task(time.time(), state_dir)),
    ]


def run_background_tasks(
    tasks: Sequence[Task] | None = None,
    state_dir: str | None = None,
) -> list[str]:
    """Run each background task once, in order.

    A failing task prints a warning, and the remaining tasks still run.  Only
    one run happens at a time: a run that finds another one in progress
    exits without running any task.

    Parameters
    ----------
    tasks : Sequence[Task] | None, optional
        ``(name, callable)`` pairs to run.  Defaults to the standard tasks.
    state_dir : str | None, optional
        Directory for state files and the run lock.  Defaults to
        ``<XDG_CACHE_HOME>/koopa/background-tasks``.

    Returns
    -------
    list[str]
        Names of the tasks that failed.
    """
    state_dir = state_dir or _state_dir()
    os.makedirs(state_dir, exist_ok=True)
    with open(os.path.join(state_dir, "lock"), "w") as lock_fh:
        try:
            fcntl.flock(lock_fh, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            alert_note("background-tasks: another run is in progress; skipping.")
            return []
        run_list = tasks if tasks is not None else _default_tasks(state_dir)
        failed: list[str] = []
        for name, task in run_list:
            try:
                task()
            # SystemExit too: organize_screenshots() raises it for a missing
            # folder, and it must not skip the tasks after it.
            except (Exception, SystemExit) as exc:
                warn(f"background-tasks: {name} failed: {exc}")
                failed.append(name)
        return failed
