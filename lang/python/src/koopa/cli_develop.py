"""Dispatch table for ``koopa develop`` subcommands.

Replaces the 34-line ``_koopa_cli_develop`` Bash function.
"""

from __future__ import annotations

import sys

_DEVELOP_COMMANDS: dict[str, str] = {
    "log": "view-latest-tmp-log-file",
    "cache-functions": "cache-functions",
    "edit-app-json": "edit-app-json",
    "push-all-app-builds": "push-all-app-builds",
    "push-app-build": "push-app-build",
    "roff": "roff",
}


def _handle_prune_app_binaries() -> None:
    """Handle ``koopa develop prune-app-binaries``."""
    from koopa.app import prune_app_binaries

    prune_app_binaries()


def handle_develop(remainder: list[str]) -> None:
    """Dispatch ``koopa develop ...`` commands."""
    if not remainder:
        print("Error: no develop command specified.", file=sys.stderr)
        sys.exit(1)
    if remainder[-1] in ("--help", "-h"):
        from koopa.cli_help import show_man_page

        show_man_page("develop", *remainder[:-1])
        return
    subcmd = remainder[0]
    rest = remainder[1:]
    if subcmd == "prune-app-binaries":
        _handle_prune_app_binaries()
        return
    key = _DEVELOP_COMMANDS.get(subcmd)
    if key is None:
        print(f"Error: unknown develop command '{subcmd}'.", file=sys.stderr)
        sys.exit(1)
    from koopa.cli_app import _run_bash_function

    _run_bash_function(key, *rest)
