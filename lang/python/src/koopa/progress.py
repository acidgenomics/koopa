"""Build progress tracking with historical timing."""

from __future__ import annotations

import json
import os
import time
from pathlib import Path

_HISTORY_FILENAME = "build-times.json"

_active_progress: BuildProgress | None = None


def get_active_progress() -> BuildProgress | None:
    """Return the currently active build progress context, if any."""
    return _active_progress


def _history_path() -> str:
    """Return path to the build-times JSON file under koopa config."""
    koopa_prefix = os.environ.get(
        "KOOPA_PREFIX",
        str(Path(__file__).resolve().parents[4]),
    )
    return os.path.join(koopa_prefix, "etc", "koopa", _HISTORY_FILENAME)


def _load_history() -> dict[str, float]:
    """Load build timing history from disk."""
    path = _history_path()
    if not os.path.isfile(path):
        return {}
    try:
        with open(path) as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError):
        return {}


def _save_history(history: dict[str, float]) -> None:
    """Save build timing history to disk."""
    path = _history_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    try:
        with open(path, "w") as f:
            json.dump(history, f, indent=2, sort_keys=True)
    except OSError:
        pass


def _fmt_duration(seconds: float) -> str:
    """Format seconds as a human-readable duration string."""
    seconds = int(seconds)
    if seconds < 60:
        return f"{seconds}s"
    minutes, secs = divmod(seconds, 60)
    if minutes < 60:
        return f"{minutes}m{secs:02d}s"
    hours, minutes = divmod(minutes, 60)
    return f"{hours}h{minutes:02d}m"


class BuildProgress:
    """Track build elapsed time and record historical timing.

    No live display — build output flows through to the terminal unimpeded.
    Elapsed time is reported by the caller after the context exits.

    Usage::

        with BuildProgress("gcc") as progress:
            run_the_build()
        print(f"Done in {progress.elapsed_formatted}")
    """

    def __init__(self, name: str, *, quiet: bool = False) -> None:
        self._name = name
        self._quiet = quiet
        self._start: float = 0.0
        self._elapsed: float = 0.0

    def __enter__(self) -> BuildProgress:
        global _active_progress  # noqa: PLW0603
        _active_progress = self
        self._start = time.monotonic()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:  # noqa: ANN001
        global _active_progress  # noqa: PLW0603
        _active_progress = None
        self._elapsed = time.monotonic() - self._start
        if exc_type is None:
            self._record_duration()

    @property
    def elapsed(self) -> float:
        """Return elapsed seconds since the build started."""
        if self._start == 0.0:
            return 0.0
        return time.monotonic() - self._start

    @property
    def elapsed_formatted(self) -> str:
        """Return elapsed time as a human-readable string."""
        return _fmt_duration(self._elapsed if self._elapsed else self.elapsed)

    def switch_to_step_mode(self, total: int) -> bool:
        """No-op retained for API compatibility."""
        return False

    def update_steps(self, current: int, total: int) -> None:
        """No-op retained for API compatibility."""

    def _record_duration(self) -> None:
        history = _load_history()
        history[self._name] = round(self._elapsed, 1)
        _save_history(history)
