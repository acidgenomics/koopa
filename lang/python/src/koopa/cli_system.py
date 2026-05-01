"""Dispatch table for ``koopa system`` subcommands.

Replaces the 117-line ``_koopa_cli_system`` Bash function.
"""

from __future__ import annotations

import sys


def _run_bash(key: str, *args: str) -> None:
    """Delegate to a Bash function via header.sh."""
    from koopa.cli_app import _run_bash_function

    _run_bash_function(key, *args)


def _handle_prefix(args: list[str]) -> None:
    """Handle ``koopa system prefix [name]``."""
    from koopa.prefix import koopa_prefix

    if not args or args[0] == "koopa":
        print(koopa_prefix())
    else:
        _run_bash(f"{args[0]}-prefix", *args[1:])


def _handle_version(args: list[str]) -> None:
    """Handle ``koopa system version [name]``."""
    _run_bash("get-version", *args)


def _handle_which(args: list[str]) -> None:
    """Handle ``koopa system which [name]``."""
    _run_bash("which-realpath", *args)


def _handle_list(args: list[str]) -> None:
    """Handle ``koopa system list`` subcommands."""
    if not args:
        print("Error: no list subcommand specified.", file=sys.stderr)
        sys.exit(1)
    subcmd = args[0]
    rest = args[1:]
    list_cmds = {
        "app-versions": "list-app-versions",
        "dotfiles": "list-dotfiles",
        "launch-agents": "list-launch-agents",
        "path-priority": "list-path-priority",
        "programs": "list-programs",
    }
    key = list_cmds.get(subcmd)
    if key is None:
        msg = f"Unknown list subcommand: '{subcmd}'."
        print(f"Error: {msg}", file=sys.stderr)
        sys.exit(1)
    _run_bash(key, *rest)


def _handle_prune_apps() -> None:
    """Handle ``koopa system prune-apps``."""
    from koopa.app import prune_apps

    prune_apps()


def _handle_update_tex_packages() -> None:
    """Handle ``koopa system update-tex-packages``."""
    import os
    import shutil
    import subprocess

    if os.getuid() != 0:
        msg = "Admin/root access is required."
        raise PermissionError(msg)
    tlmgr = shutil.which("tlmgr")
    if tlmgr is None:
        msg = "tlmgr is not installed."
        raise FileNotFoundError(msg)
    subprocess.run(["sudo", tlmgr, "update", "--self"], check=True)
    subprocess.run(["sudo", tlmgr, "update", "--list"], check=True)
    subprocess.run(["sudo", tlmgr, "update", "--all"], check=True)


_SYSTEM_COMMANDS: dict[str, str] = {
    "check": "check-system",
    "info": "system-info",
    "disable-passwordless-sudo": "disable-passwordless-sudo",
    "enable-passwordless-sudo": "enable-passwordless-sudo",
    "hostname": "hostname",
    "os-string": "os-string",
    "switch-to-develop": "switch-to-develop",
    "test": "test",
    "zsh-compaudit-set-permissions": "zsh-compaudit-set-permissions",
    "delete-cache": "delete-cache",
    "fix-sudo-setrlimit-error": "fix-sudo-setrlimit-error",
    "spotlight": "spotlight-find",
    "clean-launch-services": "clean-launch-services",
    "create-dmg": "create-dmg",
    "disable-touch-id-sudo": "disable-touch-id-sudo",
    "enable-touch-id-sudo": "enable-touch-id-sudo",
    "flush-dns": "flush-dns",
    "force-eject": "force-eject",
    "ifactive": "ifactive",
    "reload-autofs": "reload-autofs",
}

_DEFUNCT_COMMANDS: dict[str, str] = {
    "cache-functions": "koopa develop cache-functions",
    "edit-app-json": "koopa develop edit-app-json",
    "prune-app-binaries": "koopa develop prune-app-binaries",
}


def handle_system(remainder: list[str]) -> None:  # noqa: PLR0911
    """Dispatch ``koopa system ...`` commands."""
    if not remainder:
        print("Error: no system command specified.", file=sys.stderr)
        sys.exit(1)
    if remainder[-1] in ("--help", "-h"):
        from koopa.cli_help import show_man_page

        show_man_page("system", *remainder[:-1])
        return
    subcmd = remainder[0]
    rest = remainder[1:]
    if subcmd in _DEFUNCT_COMMANDS:
        replacement = _DEFUNCT_COMMANDS[subcmd]
        print(f"Defunct. Use '{replacement}' instead.", file=sys.stderr)
        sys.exit(1)
    if subcmd == "prefix":
        _handle_prefix(rest)
        return
    if subcmd == "version":
        _handle_version(rest)
        return
    if subcmd == "which":
        _handle_which(rest)
        return
    if subcmd == "list":
        _handle_list(rest)
        return
    if subcmd == "prune-apps":
        _handle_prune_apps()
        return
    if subcmd == "update-tex-packages":
        _handle_update_tex_packages()
        return
    key = _SYSTEM_COMMANDS.get(subcmd)
    if key is None:
        print(f"Error: unknown system command '{subcmd}'.", file=sys.stderr)
        sys.exit(1)
    _run_bash(key, *rest)
