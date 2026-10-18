#!/usr/bin/env python3
"""SessionStart hook: tell the model the user's local time zone, so the times it shows are local.

CLAUDE CODE ONLY. Registered under `SessionStart` in `hooks/hooks.json` and absent from the
Copilot registry, since Copilot already states the current date and time with its offset.
Self-gating: it does nothing unless `CLAUDE_PROJECT_DIR` is set, so Codex reading the same
file is unaffected.

The zone is the machine's own: `TZ` when set, else the IANA name that `/etc/localtime` links
into (macOS and Linux both keep that link), else the system's abbreviation. One line goes to
stdout, which Claude Code adds to the session context.

Never blocks: every path exits 0 and any error prints nothing.
"""

import os
import sys
from datetime import datetime

_ZONEINFO = "zoneinfo/"


def zone_name() -> str:
    """Return the local IANA zone name, or the system abbreviation when none is found."""
    tz = os.environ.get("TZ", "").lstrip(":")
    if tz:
        return tz
    try:
        target = os.path.realpath("/etc/localtime")
    except OSError:
        target = ""
    if _ZONEINFO in target:
        return target.split(_ZONEINFO, 1)[1]
    return datetime.now().astimezone().tzname() or "unknown"


def message(now: datetime | None = None) -> str:
    """Return the one-line context message for the local zone."""
    local = (now or datetime.now()).astimezone()
    offset = local.strftime("%z")
    offset = f"UTC{offset[:3]}:{offset[3:]}" if offset else "UTC offset unknown"
    return (
        f"The user's local time zone is {zone_name()} ({offset}, {local.tzname()}). "
        "Show times in this zone unless asked otherwise.\n"
    )


def main() -> None:
    """Print the time zone line when running under Claude Code."""
    if os.environ.get("CLAUDE_PROJECT_DIR"):
        sys.stdout.write(message())


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(
            f"session_local_time: skipped after an internal error ({type(error).__name__})",
            file=sys.stderr,
        )
    sys.exit(0)
