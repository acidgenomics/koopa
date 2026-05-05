"""Generate koopa.1 man page in roff format.

Auto-generates ``share/man/man1/koopa.1`` by reusing the authoritative
command/platform tables from ``generate_completion.py`` and the handler
registry in ``cli_develop.py``. Only descriptions and argument synopses
live here — command names and platform tags are never duplicated.

Usage::

    koopa develop generate-man          # print to stdout
    koopa develop generate-man --write  # overwrite koopa.1
"""

from __future__ import annotations

import os
from datetime import date

# ---------------------------------------------------------------------------
# Descriptions and synopsis hints — the only data that lives exclusively here.
# Keys must match the plain (un-escaped) command name in the source tables.
# ---------------------------------------------------------------------------

_SYSTEM_DESCRIPTIONS: dict[str, str] = {
    "check": (
        "Run system checks, including dependency versions, broken app installs,"
        " bootstrap version, and disk usage."
    ),
    "clean-launch-services": "Clean the macOS Launch Services database.",
    "create-dmg": "Create a DMG disk image.",
    "delete-cache": "Delete cache, log, and temporary files (Docker images only).",
    "disable-passwordless-sudo": "Disable passwordless sudo for the current user.",
    "disable-touch-id-sudo": "Disable Touch ID for sudo authentication.",
    "enable-passwordless-sudo": "Enable passwordless sudo for the current user.",
    "enable-touch-id-sudo": "Enable Touch ID for sudo authentication.",
    "fix-sudo-setrlimit-error": "Fix the sudo setrlimit error on Linux.",
    "flush-dns": "Flush the DNS cache.",
    "force-eject": "Force eject a mounted volume.",
    "hostname": "Print the system hostname.",
    "ifactive": "Show active network interfaces.",
    "info": "Show system information.",
    "list": "List system information (subcommands: app-versions, launch-agents, path-priority).",
    "os-string": "Print the operating system identifier string.",
    "prefix": "Print the installation prefix for koopa or a named application.",
    "prune-apps": "Remove stale application versions.",
    "reload-autofs": "Reload the autofs automount daemon.",
    "spotlight": "Search using Spotlight.",
    "switch-to-develop": "Switch koopa installation to the development branch.",
    "test": "Run the koopa test suite.",
    "update-tex-packages": "Update TeX Live packages via tlmgr.",
    "version": "Print the installed version of an application.",
    "which": "Print the real path of an application.",
    "zsh-compaudit-set-permissions": "Fix Zsh compaudit permissions.",
}

# Optional argument synopsis shown after the command name.
_SYSTEM_SYNOPSIS: dict[str, str] = {
    "list": "subcommand",
    "prefix": "[name]",
    "spotlight": "query",
    "version": "name",
    "which": "name...",
}

_DEVELOP_DESCRIPTIONS: dict[str, str] = {
    "audit-src-mirror": "Audit S3 source mirror for missing or stale tarballs.",
    "bump-revision": "Bump the revision of one or more apps in app.json.",
    "bump-venv-revision": "Bump the Python venv revision.",
    "cache-functions": "Regenerate the cached Bash function library.",
    "check-app-versions": "Check upstream versions for all apps in app.json.",
    "circular-dependencies": "Detect circular dependency chains in app.json.",
    "edit-app-json": "Open app.json in the default editor.",
    "format-app-json": "Sort and format app.json.",
    "generate-completion": "Regenerate shell tab-completion scripts.",
    "generate-man": "Regenerate the koopa(1) man page.",
    "log": "View the latest temporary log file.",
    "mirror-src": "Mirror source tarballs to S3.",
    "prune-app-binaries": "Remove stale application binaries from the cache.",
    "push-all-app-builds": "Push all application builds to the binary cache.",
    "push-app-build": "Push a specific application build to the binary cache.",
    "push-app-builds": "Push all stale application builds to the binary cache.",
    "pytest": "Run the Python test suite.",
    "remove-app": "Tombstone an app entry in app.json.",
    "shellcheck": "Run shellcheck on all shell scripts.",
    "update-docs": "Update generated documentation files.",
}

_DEVELOP_SYNOPSIS: dict[str, str] = {
    "bump-revision": "name...",
    "mirror-src": "name...",
    "push-app-build": "name...",
    "remove-app": "name",
}

# ---------------------------------------------------------------------------
# Static top-level command table.
# cli_main.py uses argparse subparsers, so there is no importable list there.
# ---------------------------------------------------------------------------

_TOP_COMMANDS: list[tuple[str, str, str]] = [
    ("install", "app...", "Install one or more applications."),
    ("reinstall", "app...", "Reinstall applications, with optional reverse dependency rebuilds."),
    (
        "uninstall",
        "[app...]",
        "Remove installed applications. Defaults to uninstalling koopa itself.",
    ),
    ("update", "[app...]", "Update applications to latest versions. Defaults to updating koopa."),
    ("configure", "app...", "Run post-install configuration for applications."),
    ("app", "subcommand", "Application-specific utilities (e.g. koopa app salmon quant)."),
    ("system", "subcommand", "System information, prefix lookups, and administration commands."),
    ("develop", "subcommand", "Developer and maintenance utilities."),
    ("internal", "subcommand", "Internal low-level utilities (not intended for direct use)."),
    ("version", "", "Print koopa version."),
    ("header", "", "Print path to the shell script header file, for use with source."),
    ("install-all-apps", "", "Install all registered applications."),
    ("install-default-apps", "", "Install the default set of applications."),
]

_INSTALL_FLAGS: list[tuple[str, str]] = [
    ("--no-dependencies", "Skip dependency installation."),
    ("--private", "Install from private sources."),
    ("--reinstall", "Force reinstall even if already installed."),
    ("--system", "Install in system mode."),
    ("--user", "Install in user mode."),
    ("-D arg", "Pass additional arguments through to the installer. Can be repeated."),
]

_REINSTALL_FLAGS: list[tuple[str, str]] = [
    ("--all-revdeps", "Reinstall the specified apps and all of their reverse dependencies."),
    ("--only-revdeps", "Reinstall only the reverse dependencies, not the specified apps."),
]

_MODE_FLAGS: list[tuple[str, str]] = [
    ("--system", "Operate in system mode."),
    ("--user", "Operate in user mode."),
]

# ---------------------------------------------------------------------------
# roff helpers
# ---------------------------------------------------------------------------


def _roff_name(text: str) -> str:
    """Escape hyphens for roff .TP term lines."""
    return text.replace("-", r"\-")


def _bold(text: str) -> str:
    return rf"\fB{text}\fR"


def _italic(text: str) -> str:
    return rf"\fI{text}\fR"


def _section(name: str) -> list[str]:
    return [".", f'.SH "{name}"']


def _subsection(name: str) -> list[str]:
    return [f'.SS "{name}"']


def _tp(term: str, desc: str) -> list[str]:
    return [".TP", term, desc]


# ---------------------------------------------------------------------------
# Main generator
# ---------------------------------------------------------------------------


def generate_man() -> str:
    """Generate the ``koopa.1`` man page in roff format."""
    from koopa.generate_completion import _SYSTEM_COMMANDS, _load_develop_commands

    month_year = date.today().strftime("%B %Y")
    lines: list[str] = []

    lines += [
        ".\\\" Auto-generated by 'koopa develop generate-man'. Do not edit manually.",
        ".",
        f'.TH "KOOPA" "1" "{month_year}" "" ""',
        ".",
    ]

    lines += _section("NAME")
    lines.append(rf"{_bold('koopa')} \- shell bootloader for data science")

    lines += _section("SYNOPSIS")
    lines.append(rf"{_bold('koopa')} {_italic('command')} [options] [args...]")

    lines += _section("DESCRIPTION")
    lines.append(
        "koopa is a shell bootloader for data science that manages installation,"
        " configuration, and updates of command-line applications and libraries."
    )

    lines += _section("GLOBAL OPTIONS")
    lines += _tp(
        rf"{_bold('--help')}, {_bold('-h')}",
        "Show help. Place after a command to view command-specific help.",
    )
    lines += _tp(_bold("--version"), "Print version information.")
    lines += _tp(_bold("--verbose"), "Enable verbose output.")

    lines += _section("COMMANDS")
    lines += _subsection("Package management")
    for name, synopsis, desc in _TOP_COMMANDS[:5]:
        term = _bold(_roff_name(name))
        if synopsis:
            term += f" {_italic(synopsis)}"
        lines += _tp(term, desc)

    lines += _subsection("Utility commands")
    for name, synopsis, desc in _TOP_COMMANDS[5:]:
        term = _bold(_roff_name(name))
        if synopsis:
            term += f" {_italic(synopsis)}"
        lines += _tp(term, desc)

    lines += _section("INSTALL OPTIONS")
    for flag, desc in _INSTALL_FLAGS:
        lines += _tp(_bold(_roff_name(flag)), desc)

    lines += _section("REINSTALL OPTIONS")
    for flag, desc in _REINSTALL_FLAGS:
        lines += _tp(_bold(_roff_name(flag)), desc)

    lines += _section("UNINSTALL / UPDATE / CONFIGURE OPTIONS")
    for flag, desc in _MODE_FLAGS:
        lines += _tp(_bold(_roff_name(flag)), desc)

    # SYSTEM SUBCOMMANDS — names/platforms from the canonical generate_completion table.
    lines += _section("SYSTEM SUBCOMMANDS")
    common = [(n, p) for n, p in _SYSTEM_COMMANDS if p is None]
    linux_cmds = [(n, p) for n, p in _SYSTEM_COMMANDS if p == "linux"]
    macos_cmds = [(n, p) for n, p in _SYSTEM_COMMANDS if p == "macos"]

    for name, _ in common:
        term = _bold(f"system {_roff_name(name)}")
        synopsis = _SYSTEM_SYNOPSIS.get(name, "")
        if synopsis:
            term += f" {_italic(synopsis)}"
        lines += _tp(term, _SYSTEM_DESCRIPTIONS.get(name, ""))

    if linux_cmds:
        lines += _subsection(r"Linux\-specific system subcommands")
        for name, _ in linux_cmds:
            lines += _tp(_bold(f"system {_roff_name(name)}"), _SYSTEM_DESCRIPTIONS.get(name, ""))

    if macos_cmds:
        lines += _subsection(r"macOS\-specific system subcommands")
        for name, _ in macos_cmds:
            term = _bold(f"system {_roff_name(name)}")
            synopsis = _SYSTEM_SYNOPSIS.get(name, "")
            if synopsis:
                term += f" {_italic(synopsis)}"
            lines += _tp(term, _SYSTEM_DESCRIPTIONS.get(name, ""))

    # DEVELOP SUBCOMMANDS — names from _DEVELOP_HANDLERS via _load_develop_commands().
    lines += _section("DEVELOP SUBCOMMANDS")
    for name in _load_develop_commands():
        term = _bold(f"develop {_roff_name(name)}")
        synopsis = _DEVELOP_SYNOPSIS.get(name, "")
        if synopsis:
            term += f" {_italic(synopsis)}"
        lines += _tp(term, _DEVELOP_DESCRIPTIONS.get(name, ""))

    lines += _section("COPYRIGHT")
    lines.append("This software is provided under the GNU General Public License v3.0.")
    lines.append(r"See \fBLICENSE\fR file for details.")

    return "\n".join(lines) + "\n"


def write_man(*, path: str = "") -> None:
    """Write ``koopa.1`` to disk."""
    from koopa.prefix import koopa_prefix

    if not path:
        path = os.path.join(koopa_prefix(), "share", "man", "man1", "koopa.1")
    content = generate_man()
    with open(path, "w") as fh:
        fh.write(content)
