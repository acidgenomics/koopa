"""Generate koopa.1 man page in roff format.

Auto-generates ``share/man/man1/koopa.1`` from static description tables
that mirror the actual dispatch tables in cli_main.py, cli_system.py, and
cli_develop.py.

Usage::

    koopa develop generate-man          # print to stdout
    koopa develop generate-man --write  # overwrite koopa.1
"""

from __future__ import annotations

import os
from datetime import date

# ---------------------------------------------------------------------------
# Description tables
# ---------------------------------------------------------------------------

_TOP_COMMANDS: list[tuple[str, str, str]] = [
    # (name, synopsis, description)
    ("install", "<app>...", "Install one or more applications."),
    ("reinstall", "<app>...", "Reinstall applications, with optional reverse dependency rebuilds."),
    ("uninstall", "[<app>...]", "Remove installed applications. Defaults to uninstalling koopa itself."),
    ("update", "[<app>...]", "Update applications to latest versions. Defaults to updating koopa."),
    ("configure", "<app>...", "Run post-install configuration for applications."),
    ("app", "<subcommand>", r"Application\-specific utilities (e.g. \fBkoopa app salmon quant\fR)."),
    ("system", "<subcommand>", "System information, prefix lookups, and administration commands."),
    ("develop", "<subcommand>", "Developer and maintenance utilities."),
    ("internal", "<subcommand>", r"Internal low\-level utilities (not intended for direct use)."),
    ("version", "", "Print koopa version."),
    ("header", "", r"Print path to the shell script header file, for use with \fBsource\fR."),
    ("install-all-apps", "", "Install all registered applications."),
    ("install-default-apps", "", "Install the default set of applications."),
]

_INSTALL_OPTIONS: list[tuple[str, str]] = [
    (r"\-\-no\-dependencies", "Skip dependency installation."),
    (r"\-\-private", "Install from private sources."),
    (r"\-\-reinstall", "Force reinstall even if already installed."),
    (r"\-\-system", "Install in system mode."),
    (r"\-\-user", "Install in user mode."),
    (r"\-D \fIarg\fR", r"Pass additional arguments through to the installer. Can be repeated."),
]

_REINSTALL_OPTIONS: list[tuple[str, str]] = [
    (r"\-\-all\-revdeps", r"Reinstall the specified apps and all of their reverse dependencies."),
    (r"\-\-only\-revdeps", "Reinstall only the reverse dependencies, not the specified apps."),
]

_MODE_OPTIONS: list[tuple[str, str]] = [
    (r"\-\-system", "Operate in system mode."),
    (r"\-\-user", "Operate in user mode."),
]

_SYSTEM_COMMANDS: list[tuple[str, str, str | None]] = [
    # (name, description, platform)  platform: None=all, "macos", "linux"
    ("check", "Run system checks, including dependency versions, broken app installs, bootstrap version, and disk usage.", None),
    ("info", "Show system information.", None),
    (r"prefix [\fIname\fR]", r"Print the installation prefix for koopa or a named application.", None),
    (r"version \fIname\fR", "Print the installed version of an application.", None),
    (r"which \fIname\fR", "Print the real path of an application.", None),
    (r"list \fIsubcommand\fR", r"List system information. Subcommands: \fBapp\-versions\fR, \fBlaunch\-agents\fR, \fBpath\-priority\fR.", None),
    ("prune-apps", "Remove stale application versions.", None),
    (r"update\-tex\-packages", r"Update TeX Live packages via \fBtlmgr\fR.", None),
    ("hostname", "Print the system hostname.", None),
    (r"os\-string", "Print the operating system identifier string.", None),
    (r"switch\-to\-develop", "Switch koopa installation to the development branch.", None),
    ("test", "Run the koopa test suite.", None),
    (r"delete\-cache", "Delete cache, log, and temporary files (Docker images only).", None),
    (r"enable\-passwordless\-sudo", "Enable passwordless sudo for the current user.", None),
    (r"disable\-passwordless\-sudo", "Disable passwordless sudo for the current user.", None),
    (r"zsh\-compaudit\-set\-permissions", "Fix Zsh compaudit permissions.", None),
    (r"fix\-sudo\-setrlimit\-error", "Fix the sudo setrlimit error on Linux.", "linux"),
    (r"clean\-launch\-services", "Clean the macOS Launch Services database.", "macos"),
    (r"create\-dmg", "Create a DMG disk image.", "macos"),
    (r"enable\-touch\-id\-sudo", "Enable Touch ID for sudo authentication.", "macos"),
    (r"disable\-touch\-id\-sudo", "Disable Touch ID for sudo authentication.", "macos"),
    (r"flush\-dns", "Flush the DNS cache.", "macos"),
    (r"force\-eject", "Force eject a mounted volume.", "macos"),
    ("ifactive", "Show active network interfaces.", "macos"),
    (r"reload\-autofs", "Reload the autofs automount daemon.", "macos"),
    (r"spotlight \fIquery\fR", "Search using Spotlight.", "macos"),
]

_DEVELOP_COMMANDS: list[tuple[str, str]] = [
    ("log", "View the latest temporary log file."),
    (r"cache\-functions", "Regenerate the cached Bash function library."),
    (r"edit\-app\-json", r"Open \fBapp.json\fR in the default editor."),
    (r"format\-app\-json", r"Sort and format \fBapp.json\fR."),
    (r"check\-app\-versions", r"Check upstream versions for all apps in \fBapp.json\fR."),
    (r"update\-docs", "Update generated documentation files."),
    (r"generate\-completion", "Regenerate shell tab-completion scripts."),
    (r"generate\-man", r"Regenerate the \fBkoopa\fR(1) man page."),
    ("roff", r"Regenerate man pages from \fB.ronn\fR source files (requires \fBronn\fR)."),
    (r"push\-app\-build \fIname\fR...", "Push a specific application build to the binary cache."),
    (r"push\-app\-builds", "Push all stale application builds to the binary cache."),
    (r"push\-all\-app\-builds", "Push all application builds to the binary cache."),
    (r"prune\-app\-binaries", "Remove stale application binaries from the cache."),
    (r"mirror\-src \fIname\fR...", "Mirror source tarballs to S3."),
    (r"audit\-src\-mirror", "Audit S3 source mirror for missing or stale tarballs."),
    (r"remove\-app \fIname\fR", r"Tombstone an app entry in \fBapp.json\fR."),
    (r"bump\-revision \fIname\fR...", r"Bump the revision of one or more apps in \fBapp.json\fR."),
    (r"bump\-venv\-revision", "Bump the Python venv revision."),
    ("shellcheck", "Run shellcheck on all shell scripts."),
    (r"circular\-dependencies", r"Detect circular dependency chains in \fBapp.json\fR."),
    ("pytest", "Run the Python test suite."),
]

# ---------------------------------------------------------------------------
# roff helpers
# ---------------------------------------------------------------------------


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
    month_year = date.today().strftime("%B %Y")
    lines: list[str] = []

    # Header
    lines += [
        ".\\" + "\" Auto-generated by 'koopa develop generate-man'. Do not edit manually.",
        ".",
        f'.TH "KOOPA" "1" "{month_year}" "" ""',
        ".",
    ]

    # NAME
    lines += _section("NAME")
    lines.append(r"\fBkoopa\fR \- shell bootloader for data science")

    # SYNOPSIS
    lines += _section("SYNOPSIS")
    lines.append(r"\fBkoopa\fR \fIcommand\fR [options] [args\.\.\.]")

    # DESCRIPTION
    lines += _section("DESCRIPTION")
    lines.append(
        r"koopa is a shell bootloader for data science that manages installation,"
        r" configuration, and updates of command\-line applications and libraries."
    )

    # GLOBAL OPTIONS
    lines += _section("GLOBAL OPTIONS")
    lines += _tp(r"\fB\-\-help\fR, \fB\-h\fR", r"Show help\. Place after a command to view command\-specific help.")
    lines += _tp(r"\fB\-\-version\fR, \fB\-V\fR", "Print version information.")
    lines += _tp(r"\fB\-\-verbose\fR", "Enable verbose output.")

    # COMMANDS
    lines += _section("COMMANDS")
    lines += _subsection("Package management")
    for name, synopsis, desc in _TOP_COMMANDS[:5]:
        term = rf"\fB{name}\fR"
        if synopsis:
            term += rf" \fI{synopsis}\fR"
        lines += _tp(term, desc)

    lines += _subsection("Utility commands")
    for name, synopsis, desc in _TOP_COMMANDS[5:]:
        term = rf"\fB{name}\fR"
        if synopsis:
            term += rf" \fI{synopsis}\fR"
        lines += _tp(term, desc)

    # INSTALL OPTIONS
    lines += _section("INSTALL OPTIONS")
    for flag, desc in _INSTALL_OPTIONS:
        lines += _tp(rf"\fB{flag}\fR", desc)

    # REINSTALL OPTIONS
    lines += _section("REINSTALL OPTIONS")
    for flag, desc in _REINSTALL_OPTIONS:
        lines += _tp(rf"\fB{flag}\fR", desc)

    # UNINSTALL / UPDATE / CONFIGURE OPTIONS
    lines += _section("UNINSTALL / UPDATE / CONFIGURE OPTIONS")
    for flag, desc in _MODE_OPTIONS:
        lines += _tp(rf"\fB{flag}\fR", desc)

    # SYSTEM SUBCOMMANDS
    lines += _section("SYSTEM SUBCOMMANDS")
    common = [(n, d) for n, d, p in _SYSTEM_COMMANDS if p is None]
    linux_cmds = [(n, d) for n, d, p in _SYSTEM_COMMANDS if p == "linux"]
    macos_cmds = [(n, d) for n, d, p in _SYSTEM_COMMANDS if p == "macos"]

    for name, desc in common:
        lines += _tp(rf"\fBsystem {name}\fR", desc)

    if linux_cmds:
        lines += _subsection(r"Linux\-specific system subcommands")
        for name, desc in linux_cmds:
            lines += _tp(rf"\fBsystem {name}\fR", desc)

    if macos_cmds:
        lines += _subsection(r"macOS\-specific system subcommands")
        for name, desc in macos_cmds:
            lines += _tp(rf"\fBsystem {name}\fR", desc)

    # DEVELOP SUBCOMMANDS
    lines += _section("DEVELOP SUBCOMMANDS")
    for name, desc in _DEVELOP_COMMANDS:
        lines += _tp(rf"\fBdevelop {name}\fR", desc)

    # COPYRIGHT
    lines += _section("COPYRIGHT")
    lines.append(r"This software is provided under the GNU General Public License v3\.0\.")
    lines.append(r"See \fBLICENSE\fR file for details\.")

    return "\n".join(lines) + "\n"


def write_man(*, path: str = "") -> None:
    """Write ``koopa.1`` to disk."""
    from koopa.prefix import koopa_prefix

    if not path:
        path = os.path.join(koopa_prefix(), "share", "man", "man1", "koopa.1")
    content = generate_man()
    with open(path, "w") as fh:
        fh.write(content)
