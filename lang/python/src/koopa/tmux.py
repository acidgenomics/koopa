"""Tmux server helpers: config reload and binary-drift detection."""

import os
import subprocess

from koopa.alert import warn
from koopa.prefix import bin_prefix
from koopa.version import extract_version
from koopa.xdg import xdg_config_home


def _bundled_tmux() -> str | None:
    """Return the path to the koopa-bundled tmux binary, or None if absent."""
    path = os.path.join(bin_prefix(), "tmux")
    return path if os.path.isfile(path) else None


def tmux_server_is_stale() -> bool:
    """Return True when a running tmux server predates the on-disk bundled binary.

    Compares the version the running server was started with
    (``tmux display-message -p '#{version}'``) against the on-disk bundled
    binary version (``tmux -V``).  Returns False when no server is running or
    when the bundled tmux binary is absent — nothing to warn about in either
    case.
    """
    tmux = _bundled_tmux()
    if tmux is None:
        return False
    try:
        disk_out = subprocess.run(
            [tmux, "-V"],
            capture_output=True,
            text=True,
            check=True,
        )
    except OSError, subprocess.CalledProcessError:
        return False
    disk_ver = extract_version(disk_out.stdout or disk_out.stderr)
    if not disk_ver:
        return False
    # check=False is intentional: "no server running" is an expected non-zero
    # exit, not an error.  We gate on returncode below.
    srv_result = subprocess.run(
        [tmux, "display-message", "-p", "#{version}"],
        capture_output=True,
        text=True,
        check=False,
    )
    if srv_result.returncode != 0:
        return False
    srv_ver = extract_version(srv_result.stdout or srv_result.stderr)
    if not srv_ver:
        return False
    return srv_ver != disk_ver


def reload_tmux_config(color_mode: str | None = None) -> None:
    """Hot-reload the tmux config into any running server.

    Safe and non-destructive: only calls ``source-file`` — no sessions or
    panes are affected.  If ``color_mode`` is provided, it is pushed into the
    server's global environment as ``KOOPA_COLOR_MODE`` before sourcing so the
    initial-palette ``if-shell`` in ``tmux.conf`` picks up the current mode.

    Silently does nothing when no bundled tmux is present or when no server is
    running.  A CalledProcessError (e.g. protocol mismatch between a very
    stale server and a newer binary) is caught and emitted as a warning so it
    never aborts the caller.
    """
    tmux = _bundled_tmux()
    if tmux is None:
        return
    # check=False: "no server running" is expected, not an error.
    has_server = subprocess.run(
        [tmux, "has-session"],
        capture_output=True,
        check=False,
    )
    if has_server.returncode != 0:
        return
    tmux_conf = os.path.join(xdg_config_home(), "tmux", "tmux.conf")
    if not os.path.isfile(tmux_conf):
        return
    try:
        if color_mode:
            subprocess.run(
                [tmux, "set-environment", "-g", "KOOPA_COLOR_MODE", color_mode],
                check=True,
            )
        subprocess.run([tmux, "source-file", tmux_conf], check=True)
    except subprocess.CalledProcessError as exc:
        warn(f"Could not reload tmux config: {exc}")


def warn_tmux_stale() -> bool:
    """Warn when the running tmux server's binary lags the on-disk version.

    Returns True when the server is current (or absent), False when stale.
    Emits a ``warn()`` message with the exact kill-server remedy so the user
    knows what to do.  Never auto-kills sessions.
    """
    tmux = _bundled_tmux()
    if tmux is None:
        return True
    if not tmux_server_is_stale():
        return True
    # Re-read both versions for the warning text (tmux_server_is_stale already
    # verified they differ; we just need the strings for display).
    try:
        disk_out = subprocess.run([tmux, "-V"], capture_output=True, text=True, check=True)
        disk_ver = extract_version(disk_out.stdout or disk_out.stderr)
        srv_out = subprocess.run(
            [tmux, "display-message", "-p", "#{version}"],
            capture_output=True,
            text=True,
            check=False,
        )
        srv_ver = extract_version(srv_out.stdout or srv_out.stderr)
    except OSError, subprocess.CalledProcessError:
        return True
    warn(
        f"Running tmux server ({srv_ver}) differs from installed tmux "
        f"({disk_ver}); run 'tmux kill-server' (ends all sessions) or "
        "reconnect to adopt it."
    )
    return False
