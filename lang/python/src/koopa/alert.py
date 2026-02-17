"""Messaging, alerting, and formatting functions.

Converted from Bash functions: alert, alert-info, alert-note, alert-success,
alert-install-start, h1-h7, dl, stop, warn, invalid-arg, etc.
"""

from __future__ import annotations

import os
import sys


def _supports_color() -> bool:
    """Check if terminal supports color."""
    if os.environ.get("NO_COLOR"):
        return False
    term = os.environ.get("TERM", "")
    return "color" in term or term == "xterm" or os.environ.get("COLORTERM", "") != ""


def ansi_escape(code: str) -> str:
    """Return ANSI escape sequence if color is supported."""
    if _supports_color():
        return f"\033[{code}m"
    return ""


def _reset() -> str:
    return ansi_escape("0")


def _bold() -> str:
    return ansi_escape("1")


def _red() -> str:
    return ansi_escape("31")


def _green() -> str:
    return ansi_escape("32")


def _yellow() -> str:
    return ansi_escape("33")


def _blue() -> str:
    return ansi_escape("34")


def _magenta() -> str:
    return ansi_escape("35")


def _cyan() -> str:
    return ansi_escape("36")


def _white() -> str:
    return ansi_escape("37")


def msg(message: str, *, prefix: str = "", color: str = "", file: object = None) -> None:
    """Print a formatted message."""
    if file is None:
        file = sys.stderr
    reset = _reset()
    c = ansi_escape(color) if color else ""
    if prefix:
        print(f"{c}{prefix}{reset} {message}", file=file)
    else:
        print(f"{c}{message}{reset}", file=file)


def alert(message: str) -> None:
    """Print an alert message."""
    msg(message, prefix="=>", color="35")


def alert_info(message: str) -> None:
    """Print an info message."""
    msg(message, prefix="ℹ", color="36")


def alert_note(message: str) -> None:
    """Print a note message."""
    msg(message, prefix="**", color="33")


def alert_success(message: str) -> None:
    """Print a success message."""
    msg(message, prefix="✓", color="32")


def alert_coffee_time() -> None:
    """Print coffee time message."""
    msg("This is going to take a while. Time for a coffee break! ☕", prefix="", color="33")


def alert_install_start(name: str, prefix: str = "") -> None:
    """Alert that installation is starting."""
    s = f"Installing {name}"
    if prefix:
        s += f" at '{prefix}'"
    s += "."
    msg(s, prefix="", color="33")


def alert_install_success(name: str, prefix: str = "") -> None:
    """Alert that installation succeeded."""
    s = f"Successfully installed {name}"
    if prefix:
        s += f" at '{prefix}'"
    s += "."
    msg(s, prefix="✓", color="32")


def alert_uninstall_start(name: str, prefix: str = "") -> None:
    """Alert that uninstallation is starting."""
    s = f"Uninstalling {name}"
    if prefix:
        s += f" at '{prefix}'"
    s += "."
    msg(s, prefix="", color="33")


def alert_uninstall_success(name: str, prefix: str = "") -> None:
    """Alert that uninstallation succeeded."""
    s = f"Successfully uninstalled {name}"
    if prefix:
        s += f" at '{prefix}'"
    s += "."
    msg(s, prefix="✓", color="32")


def alert_configure_start(name: str) -> None:
    """Alert configuration starting."""
    msg(f"Configuring {name}.", prefix="", color="33")


def alert_configure_success(name: str) -> None:
    """Alert configuration succeeded."""
    msg(f"Successfully configured {name}.", prefix="✓", color="32")


def alert_update_start(name: str) -> None:
    """Alert update starting."""
    msg(f"Updating {name}.", prefix="", color="33")


def alert_update_success(name: str) -> None:
    """Alert update succeeded."""
    msg(f"Successfully updated {name}.", prefix="✓", color="32")


def alert_process_start(name: str) -> None:
    """Alert process starting."""
    msg(f"Processing {name}.", prefix="", color="33")


def alert_process_success(name: str) -> None:
    """Alert process succeeded."""
    msg(f"Successfully processed {name}.", prefix="✓", color="32")


def alert_is_not_installed(name: str) -> None:
    """Alert that something is not installed."""
    msg(f"{name} is not installed.", prefix="", color="33")


def alert_restart() -> None:
    """Alert that restart is required."""
    msg("Restart is required.", prefix="⚠", color="33")


def h(level: int, message: str) -> None:
    """Print a header at a given level (1-7)."""
    headers = {
        1: ("", "36;1"),
        2: ("", "35;1"),
        3: ("", "34;1"),
        4: ("", "33;1"),
        5: ("", "32;1"),
        6: ("", "31;1"),
        7: ("", "37;1"),
    }
    prefix_char, color = headers.get(level, ("", "37"))
    msg(message, prefix=prefix_char, color=color)


def h1(message: str) -> None:
    """Print level 1 header."""
    h(1, message)


def h2(message: str) -> None:
    """Print level 2 header."""
    h(2, message)


def h3(message: str) -> None:
    """Print level 3 header."""
    h(3, message)


def h4(message: str) -> None:
    """Print level 4 header."""
    h(4, message)


def h5(message: str) -> None:
    """Print level 5 header."""
    h(5, message)


def h6(message: str) -> None:
    """Print level 6 header."""
    h(6, message)


def h7(message: str) -> None:
    """Print level 7 header."""
    h(7, message)


def dl(key: str, value: str) -> None:
    """Print a definition list entry (key: value)."""
    c = _magenta()
    r = _reset()
    print(f"  {c}{key}{r}: {value}", file=sys.stderr)


def dl_pairs(pairs: list[tuple[str, str]]) -> None:
    """Print multiple definition list entries."""
    for k, v in pairs:
        dl(k, v)


def stop(message: str) -> None:
    """Print error message and exit."""
    c = _red()
    r = _reset()
    print(f"{c}Error:{r} {message}", file=sys.stderr)
    sys.exit(1)


def warn(message: str) -> None:
    """Print a warning message."""
    c = _yellow()
    r = _reset()
    print(f"{c}Warning:{r} {message}", file=sys.stderr)


def invalid_arg(arg: str) -> None:
    """Print invalid argument error and exit."""
    stop(f"Invalid argument: '{arg}'.")
