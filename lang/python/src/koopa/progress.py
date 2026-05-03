"""Build progress tracking with historical timing."""

from __future__ import annotations

import json
import os
import sys
import tempfile
import threading
import time
from pathlib import Path

_HISTORY_FILENAME = "build-times.json"

_active_progress: BuildProgress | None = None

_SPINNER_FRAMES = ("|", "/", "-", "\\")
_LOG_TAIL_LINES = 200


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
    """Track build elapsed time and optional step progress.

    When ``verbose`` is False (the default), stdout and stderr are redirected
    to a temporary log file and a spinner is shown on the terminal. On failure
    the last 200 lines of the log are printed.  When ``verbose`` is True,
    output streams through to the terminal as before.
    """

    def __init__(
        self,
        name: str,
        *,
        quiet: bool = False,
        verbose: bool = False,
    ) -> None:
        self._name = name
        self._quiet = quiet
        self._verbose = verbose
        self._start: float = 0.0
        self._elapsed: float = 0.0
        self._total_steps: int = 0
        self._current_step: int = 0
        self._log_file: tempfile._TemporaryFileWrapper | None = None
        self._saved_stdout_fd: int = -1
        self._saved_stderr_fd: int = -1
        self._spinner_stop = threading.Event()
        self._spinner_thread: threading.Thread | None = None
        self._tty_fd: int = -1

    @property
    def capturing(self) -> bool:
        """True when output is being captured to a log file."""
        return self._log_file is not None

    @property
    def log_path(self) -> str | None:
        """Return path to the build log file, if capturing."""
        if self._log_file is not None:
            return self._log_file.name
        return None

    def __enter__(self) -> BuildProgress:
        """Enter the build progress context."""
        global _active_progress  # noqa: PLW0603
        _active_progress = self
        self._start = time.monotonic()
        if not self._verbose and not self._quiet:
            self._start_capture()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:  # noqa: ANN001
        """Exit the build progress context."""
        global _active_progress  # noqa: PLW0603
        _active_progress = None
        self._elapsed = time.monotonic() - self._start
        if self.capturing:
            self._stop_capture(failed=exc_type is not None)
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
        """Switch from elapsed-time mode to step-counting mode.

        When capturing, this pauses the spinner so update_steps can
        take over the tty line.
        """
        if total <= 0:
            return False
        self._total_steps = total
        self._current_step = 0
        if self.capturing:
            self._spinner_stop.set()
        return True

    def update_steps(self, current: int, total: int) -> None:
        """Update step progress with a live counter.

        In verbose mode writes to stderr. In capture mode writes to the
        saved tty fd so the progress line replaces the spinner.
        """
        self._current_step = current
        self._total_steps = total
        if self._quiet:
            return
        elapsed_secs = self.elapsed
        elapsed = _fmt_duration(elapsed_secs)
        if current > 0 and total > 0 and current < total:
            remaining_secs = (elapsed_secs / current) * (total - current)
            eta = f" ~{_fmt_duration(remaining_secs)} remaining"
        else:
            eta = ""
        line = f"\r\033[K  {self._name} [{current}/{total}] {elapsed}{eta}"
        if self.capturing and self._tty_fd >= 0:
            try:
                os.write(self._tty_fd, line.encode())
                if current >= total:
                    os.write(self._tty_fd, b"\n")
            except OSError:
                pass
        elif self._verbose:
            sys.stderr.write(line)
            sys.stderr.flush()
            if current >= total:
                sys.stderr.write("\n")

    # -- Output capture and spinner -------------------------------------------

    def _start_capture(self) -> None:
        """Redirect stdout/stderr to a temp log file and start spinner."""
        self._log_file = tempfile.NamedTemporaryFile(
            mode="w+",
            prefix="koopa-build-",
            suffix=".log",
            delete=False,
        )
        self._saved_stdout_fd = os.dup(1)
        self._saved_stderr_fd = os.dup(2)
        os.dup2(self._log_file.fileno(), 1)
        os.dup2(self._log_file.fileno(), 2)
        self._tty_fd = os.dup(self._saved_stderr_fd)
        self._spinner_stop.clear()
        self._spinner_thread = threading.Thread(
            target=self._spin,
            daemon=True,
        )
        self._spinner_thread.start()

    def _stop_capture(self, *, failed: bool) -> None:
        """Restore fds, stop spinner, optionally dump log tail."""
        self._spinner_stop.set()
        if self._spinner_thread is not None:
            self._spinner_thread.join(timeout=2)
        os.dup2(self._saved_stdout_fd, 1)
        os.dup2(self._saved_stderr_fd, 2)
        os.close(self._saved_stdout_fd)
        os.close(self._saved_stderr_fd)
        self._saved_stdout_fd = -1
        self._saved_stderr_fd = -1
        elapsed = _fmt_duration(self.elapsed)
        marker = "x" if failed else "ok"
        tty = self._tty_fd
        os.write(tty, f"\r\033[K  {self._name} {marker} [{elapsed}]\n".encode())
        if failed and self._log_file is not None:
            self._log_file.flush()
            self._dump_log_tail(tty)
        if tty >= 0:
            os.close(tty)
            self._tty_fd = -1
        if self._log_file is not None:
            log_path = self._log_file.name
            self._log_file.close()
            try:
                os.unlink(log_path)
            except OSError:
                pass
            self._log_file = None

    def _spin(self) -> None:
        """Spinner loop running on a background thread."""
        idx = 0
        tty = self._tty_fd
        if tty < 0:
            return
        while not self._spinner_stop.wait(0.2):
            frame = _SPINNER_FRAMES[idx % len(_SPINNER_FRAMES)]
            elapsed = _fmt_duration(self.elapsed)
            line = f"\r\033[K  {self._name} {frame} [{elapsed}]"
            try:
                os.write(tty, line.encode())
            except OSError:
                break
            idx += 1

    def _dump_log_tail(self, tty: int) -> None:
        """Print the last N lines of the build log to the tty."""
        if self._log_file is None:
            return
        try:
            with open(self._log_file.name) as f:
                lines = f.readlines()
        except OSError:
            return
        tail = lines[-_LOG_TAIL_LINES:]
        sep = "─" * 40
        os.write(tty, f"  Build failed. Last {_LOG_TAIL_LINES} lines:\n".encode())
        os.write(tty, f"  {sep}\n".encode())
        for line in tail:
            os.write(tty, f"  {line}".encode())
            if not line.endswith("\n"):
                os.write(tty, b"\n")
        os.write(tty, f"  {sep}\n".encode())

    def _record_duration(self) -> None:
        history = _load_history()
        history[self._name] = round(self._elapsed, 1)
        _save_history(history)
