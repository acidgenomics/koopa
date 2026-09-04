"""Messaging, alerting, and formatting functions.

Converted from Bash functions: alert, alert-info, alert-note, alert-success,
alert-install-start, h1-h7, dl, stop, warn, invalid-arg, etc.
"""

import os
import sys
from typing import TextIO

_INDENT = "   "


def _supports_color() -> bool:
    """Check if terminal supports color.

    Returns
    -------
    bool
        True if the terminal is detected to support ANSI color output.
    """
    if os.environ.get("NO_COLOR"):
        return False
    term = os.environ.get("TERM", "")
    return "color" in term or term == "xterm" or os.environ.get("COLORTERM", "") != ""


def ansi_escape(code: str) -> str:
    """Return ANSI escape sequence if color is supported.

    Parameters
    ----------
    code : str
        ANSI color or style code (e.g. ``"31"`` for red).

    Returns
    -------
    str
        ANSI escape sequence for *code*, or an empty string if color is
        not supported.
    """
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


def msg(message: str, *, prefix: str = "", color: str = "", file: TextIO | None = None) -> None:
    """Print a formatted message.

    Parameters
    ----------
    message : str
        Message text to print.
    prefix : str, optional
        Prefix string to print before the message, styled with *color*.
    color : str, optional
        ANSI color or style code to apply to the prefix, or to the whole
        message when *prefix* is empty.
    file : TextIO | None, optional
        Stream to print to. Defaults to standard error.
    """
    if file is None:
        file = sys.stderr
    reset = _reset()
    c = ansi_escape(color) if color else ""
    if prefix:
        print(f"{c}{prefix}{reset} {message}", file=file)
    else:
        print(f"{c}{message}{reset}", file=file)


def alert(message: str) -> None:
    """Print an alert message.

    Parameters
    ----------
    message : str
        Message text to print.
    """
    msg(message, prefix="=>", color="35")


def alert_info(message: str) -> None:
    """Print an indented detail line beneath a primary alert.

    Parameters
    ----------
    message : str
        Detail text to print, indented beneath the alert.
    """
    print(f"{_INDENT}{message}", file=sys.stderr)


def alert_detail(text: str) -> None:
    """Print each non-blank line of captured output as an indented detail line.

    Carriage returns are treated as line breaks so progress output captured
    from a subprocess renders one line per update instead of one long line.
    Leading whitespace within *text* is preserved, so git's own indented
    ref-update lines keep their structure.

    Parameters
    ----------
    text : str
        Captured output text, possibly multi-line or carriage-return
        delimited, to print as indented detail lines.
    """
    for line in text.replace("\r", "\n").splitlines():
        if line.strip():
            print(f"{_INDENT}{line.rstrip()}", file=sys.stderr)


def alert_note(message: str) -> None:
    """Print a note message.

    Parameters
    ----------
    message : str
        Message text to print.
    """
    msg(message, prefix="**", color="33")


def alert_success(message: str) -> None:
    """Print a success message.

    Parameters
    ----------
    message : str
        Message text to print.
    """
    msg(message, prefix="✓", color="32")


def styled_name(name: str) -> str:
    """Return bold-styled name string.

    Parameters
    ----------
    name : str
        Name to style.

    Returns
    -------
    str
        *name* wrapped in bold ANSI styling.
    """
    return f"{_bold()}{name}{_reset()}"


def styled_prefix(prefix: str) -> str:
    """Return cyan-styled prefix string.

    Parameters
    ----------
    prefix : str
        Prefix text to style.

    Returns
    -------
    str
        *prefix* wrapped in single quotes and cyan ANSI styling.
    """
    return f"'{_cyan()}{prefix}{_reset()}'"


def styled_reason(reason: str) -> str:
    """Return magenta-styled reason string.

    Parameters
    ----------
    reason : str
        Reason text to style.

    Returns
    -------
    str
        *reason* wrapped in parentheses and magenta ANSI styling.
    """
    return f"({_magenta()}{reason}{_reset()})"


def styled_version(version: str) -> str:
    """Return blue-styled version string.

    Parameters
    ----------
    version : str
        Version string to style.

    Returns
    -------
    str
        *version* wrapped in blue ANSI styling.
    """
    return f"{_blue()}{version}{_reset()}"


def alert_install_start(name: str, prefix: str = "", reason: str = "") -> None:
    """Alert that installation is starting.

    Parameters
    ----------
    name : str
        Application name.
    prefix : str, optional
        Installation prefix directory.
    reason : str, optional
        Reason the installation is happening.
    """
    s = f"Installing {styled_name(name)}"
    if prefix:
        s += f" at {styled_prefix(prefix)}"
    if reason:
        s += f" {styled_reason(reason)}"
    s += "."
    msg(s)


def alert_install_success(name: str, prefix: str = "", duration: str = "") -> None:
    """Alert that installation succeeded.

    Parameters
    ----------
    name : str
        Application name.
    prefix : str, optional
        Installation prefix directory.
    duration : str, optional
        Elapsed time the installation took, formatted for display.
    """
    s = f"Successfully installed {styled_name(name)}"
    if prefix:
        s += f" at {styled_prefix(prefix)}"
    if duration:
        s += f" in {duration}"
    s += "."
    msg(s, prefix="✓", color="32")


def alert_uninstall_start(name: str, prefix: str = "", reason: str = "") -> None:
    """Alert that uninstallation is starting.

    Parameters
    ----------
    name : str
        Application name.
    prefix : str, optional
        Installation prefix directory.
    reason : str, optional
        Reason the uninstallation is happening.
    """
    s = f"Uninstalling {styled_name(name)}"
    if prefix:
        s += f" at {styled_prefix(prefix)}"
    if reason:
        s += f" {styled_reason(reason)}"
    s += "."
    msg(s)


def alert_uninstall_success(name: str, prefix: str = "") -> None:
    """Alert that uninstallation succeeded.

    Parameters
    ----------
    name : str
        Application name.
    prefix : str, optional
        Installation prefix directory.
    """
    s = f"Successfully uninstalled {styled_name(name)}"
    if prefix:
        s += f" at {styled_prefix(prefix)}"
    s += "."
    msg(s, prefix="✓", color="32")


def alert_configure_start(name: str, reason: str = "") -> None:
    """Alert configuration starting.

    Parameters
    ----------
    name : str
        Application name.
    reason : str, optional
        Reason the configuration is happening.
    """
    s = f"Configuring {styled_name(name)}"
    if reason:
        s += f" {styled_reason(reason)}"
    s += "."
    msg(s)


def alert_configure_success(name: str) -> None:
    """Alert configuration succeeded.

    Parameters
    ----------
    name : str
        Application name.
    """
    msg(f"Successfully configured {styled_name(name)}.", prefix="✓", color="32")


def alert_update_start(name: str, reason: str = "") -> None:
    """Alert update starting.

    Parameters
    ----------
    name : str
        Application name.
    reason : str, optional
        Reason the update is happening.
    """
    s = f"Updating {styled_name(name)}"
    if reason:
        s += f" {styled_reason(reason)}"
    s += "."
    msg(s)


def alert_update_success(name: str) -> None:
    """Alert update succeeded.

    Parameters
    ----------
    name : str
        Application name.
    """
    msg(f"Successfully updated {styled_name(name)}.", prefix="✓", color="32")


def h(level: int, message: str) -> None:
    """Print a header at a given level (1-7).

    Parameters
    ----------
    level : int
        Header level, from 1 (top) to 7 (deepest).
    message : str
        Header text to print.
    """
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
    """Print level 1 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(1, message)


def h2(message: str) -> None:
    """Print level 2 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(2, message)


def h3(message: str) -> None:
    """Print level 3 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(3, message)


def h4(message: str) -> None:
    """Print level 4 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(4, message)


def h5(message: str) -> None:
    """Print level 5 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(5, message)


def h6(message: str) -> None:
    """Print level 6 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(6, message)


def h7(message: str) -> None:
    """Print level 7 header.

    Parameters
    ----------
    message : str
        Header text to print.
    """
    h(7, message)


def dl(key: str, value: str) -> None:
    """Print a definition list entry (key: value).

    Parameters
    ----------
    key : str
        Definition list key.
    value : str
        Definition list value.
    """
    print(f"{_INDENT}{key}: {value}", file=sys.stderr)


def stop(message: str) -> None:
    """Print error message and exit.

    Parameters
    ----------
    message : str
        Error message text to print before exiting.
    """
    c = _red()
    r = _reset()
    print(f"{c}Error:{r} {message}", file=sys.stderr)
    sys.exit(1)


def warn(message: str) -> None:
    """Print a warning message.

    Parameters
    ----------
    message : str
        Warning message text to print.
    """
    c = _yellow()
    r = _reset()
    print(f"{c}Warning:{r} {message}", file=sys.stderr)
