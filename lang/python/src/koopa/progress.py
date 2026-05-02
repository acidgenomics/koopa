"""Build progress display with optional tqdm support and historical timing."""

from __future__ import annotations

import json
import os
import sys
import threading
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


def _has_tqdm() -> bool:
    """Check if tqdm is importable."""
    try:
        import tqdm  # noqa: F401

        return True
    except ImportError:
        return False


class BuildProgress:
    """Display build progress with elapsed time and optional estimate.

    Uses tqdm when available for a progress bar; otherwise falls back to a
    simple text spinner on stderr.

    Usage::

        with BuildProgress("gcc") as progress:
            run_the_build()
        # elapsed time is automatically recorded on success
    """

    def __init__(self, name: str, *, quiet: bool = False) -> None:
        self._name = name
        self._quiet = quiet
        self._start: float = 0.0
        self._elapsed: float = 0.0
        self._estimate = _load_history().get(name)
        self._stop_event = threading.Event()
        self._thread: threading.Thread | None = None
        self._tqdm_bar: object | None = None
        self._step_bar: object | None = None
        self._in_step_mode: bool = False

    def __enter__(self) -> BuildProgress:
        """Enter the build progress context."""
        global _active_progress  # noqa: PLW0603
        _active_progress = self
        self._start = time.monotonic()
        if not self._quiet:
            self._start_display()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:  # noqa: ANN001
        """Exit the build progress context."""
        global _active_progress  # noqa: PLW0603
        _active_progress = None
        self._elapsed = time.monotonic() - self._start
        self._stop_display()
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
        return _fmt_duration(self._elapsed if self._elapsed else self.elapsed)

    def _start_display(self) -> None:
        if _has_tqdm() and self._estimate is not None:
            self._start_tqdm()
        else:
            self._start_fallback()

    def _stop_display(self) -> None:
        self._stop_event.set()
        if self._step_bar is not None:
            self._finish_step_mode()
        if self._tqdm_bar is not None:
            self._stop_tqdm()
        if self._thread is not None:
            self._thread.join(timeout=2)
            self._thread = None

    # -- tqdm display ---------------------------------------------------------

    def _start_tqdm(self) -> None:
        from tqdm import tqdm

        total = int(self._estimate) if self._estimate else None
        self._tqdm_bar = tqdm(
            total=total,
            desc=self._name,
            unit="s",
            bar_format=(
                "{desc}: {elapsed} elapsed | {bar} | ~{remaining} remaining"
                if total
                else "{desc}: {elapsed} elapsed"
            ),
            file=sys.stderr,
            dynamic_ncols=True,
        )
        self._thread = threading.Thread(
            target=self._tqdm_updater,
            daemon=True,
        )
        self._thread.start()

    def _tqdm_updater(self) -> None:
        bar = self._tqdm_bar
        last_n = 0
        while not self._stop_event.wait(timeout=1.0):
            elapsed_int = int(self.elapsed)
            delta = elapsed_int - last_n
            if delta > 0 and bar is not None:
                bar.update(delta)  # type: ignore[union-attr]
                last_n = elapsed_int

    def _stop_tqdm(self) -> None:
        bar = self._tqdm_bar
        if bar is not None:
            elapsed_int = int(self._elapsed)
            current = getattr(bar, "n", 0)
            delta = elapsed_int - current
            if delta > 0:
                bar.update(delta)  # type: ignore[union-attr]
            bar.close()  # type: ignore[union-attr]
        self._tqdm_bar = None

    # -- fallback spinner display ---------------------------------------------

    def _start_fallback(self) -> None:
        self._thread = threading.Thread(
            target=self._fallback_spinner,
            daemon=True,
        )
        self._thread.start()

    def _fallback_spinner(self) -> None:
        frames = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        idx = 0
        estimate_str = ""
        if self._estimate is not None:
            estimate_str = f" (typically ~{_fmt_duration(self._estimate)})"
        while not self._stop_event.wait(timeout=0.15):
            elapsed = _fmt_duration(self.elapsed)
            frame = frames[idx % len(frames)]
            line = f"\r{frame} Building {self._name}... {elapsed}{estimate_str}"
            sys.stderr.write(line)
            sys.stderr.flush()
            idx += 1
        sys.stderr.write("\r" + " " * 80 + "\r")
        sys.stderr.flush()

    # -- ninja step-mode display ----------------------------------------------

    def switch_to_step_mode(self, total: int) -> bool:
        """Replace the time-based display with a real step-count progress bar.

        Called by ``cmake_build`` when Ninja ``[N/M]`` output is detected.
        Returns ``True`` if the switch succeeded (tqdm available, not quiet).
        """
        if self._quiet or self._in_step_mode:
            return self._in_step_mode
        self._stop_event.set()
        if self._tqdm_bar is not None:
            self._stop_tqdm()
        if self._thread is not None:
            self._thread.join(timeout=2)
            self._thread = None
        self._stop_event.clear()
        self._in_step_mode = True
        if _has_tqdm():
            from tqdm import tqdm

            self._step_bar = tqdm(
                total=total,
                desc=self._name,
                unit="step",
                bar_format=(
                    "{desc}: [{n_fmt}/{total_fmt}] {bar} {percentage:3.0f}% | {elapsed} elapsed"
                ),
                file=sys.stderr,
                dynamic_ncols=True,
            )
        else:
            self._step_bar = None
        return True

    def update_steps(self, current: int, total: int) -> None:
        """Update step-mode progress from a parsed ``[current/total]`` line."""
        bar = self._step_bar
        if bar is None:
            return
        if getattr(bar, "total", None) != total:
            bar.total = total  # type: ignore[union-attr]
            bar.refresh()  # type: ignore[union-attr]
        delta = current - getattr(bar, "n", 0)
        if delta > 0:
            bar.update(delta)  # type: ignore[union-attr]

    def _finish_step_mode(self) -> None:
        """Close the step-mode progress bar."""
        bar = self._step_bar
        if bar is not None:
            bar.close()  # type: ignore[union-attr]
        self._step_bar = None
        self._in_step_mode = False

    # -- history --------------------------------------------------------------

    def _record_duration(self) -> None:
        history = _load_history()
        history[self._name] = round(self._elapsed, 1)
        _save_history(history)
