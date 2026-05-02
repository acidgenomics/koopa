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
        "launch-agents": "macos-list-launch-agents",
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


def _handle_check(args: list[str]) -> None:
    """Handle ``koopa system check``."""
    import sys

    from koopa.check import check_system

    if not check_system():
        sys.exit(1)


def _handle_system_info(args: list[str]) -> None:
    """Handle ``koopa system info``."""
    import os
    import shutil
    import subprocess

    from koopa.git import (
        git_commit_date,
        git_last_commit_local,
        git_remote_url,
        is_git_repo,
    )
    from koopa.prefix import config_prefix, koopa_prefix
    from koopa.system import arch, arch2, is_macos
    from koopa.version import koopa_version

    prefix = koopa_prefix()
    koopa_url = "https://koopa.acidgenomics.com"
    info: list[str] = [
        f"koopa {koopa_version()}",
        f"URL: {koopa_url}",
    ]
    if is_git_repo(prefix):
        info.extend([
            "",
            "Git repo",
            "--------",
            f"Remote: {git_remote_url(prefix)}",
            f"Commit: {git_last_commit_local(prefix)}",
            f"Date: {git_commit_date(prefix)}",
        ])
    bash = shutil.which("bash")
    bash_ver = ""
    if bash:
        bash = os.path.realpath(bash)
        result = subprocess.run(
            [bash, "--version"],
            capture_output=True, text=True, check=False,
        )
        first_line = result.stdout.strip().splitlines()[0] if result.stdout else ""
        import re
        m = re.search(r"(\d+\.\d+\.\d+)", first_line)
        if m:
            bash_ver = m.group(1)
    python = shutil.which("python3") or shutil.which("python") or ""
    if python:
        python = os.path.realpath(python)
    python_ver = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    if is_macos():
        result = subprocess.run(
            ["sw_vers"],
            capture_output=True, text=True, check=False,
        )
        os_str = " ".join(result.stdout.split()) if result.stdout else "macOS"
    else:
        result = subprocess.run(
            ["uname", "--all"],
            capture_output=True, text=True, check=False,
        )
        os_str = result.stdout.strip() if result.stdout else "Linux"
    info.extend([
        "",
        "Configuration",
        "-------------",
        f"Koopa Prefix: {prefix}",
        f"Config Prefix: {config_prefix()}",
        "",
        "System information",
        "------------------",
        f"OS: {os_str}",
        f"Architecture: {arch()} / {arch2()}",
        f"Bash: {bash or 'not found'}",
        f"Bash Version: {bash_ver}",
        f"Python: {python or 'not found'}",
        f"Python Version: {python_ver}",
    ])
    neofetch = shutil.which("neofetch")
    if neofetch:
        result = subprocess.run(
            [neofetch, "--stdout"],
            capture_output=True, text=True, check=False,
        )
        if result.stdout:
            nf_lines = result.stdout.strip().splitlines()
            info.extend(["", "Neofetch", "--------", *nf_lines[2:]])
    turtle_file = os.path.join(prefix, "etc", "koopa", "ascii-turtle.txt")
    if os.path.isfile(turtle_file):
        with open(turtle_file) as f:
            print(f.read(), end="")
    print("\n".join(info))


def _handle_switch_to_develop(args: list[str]) -> None:
    """Handle ``koopa system switch-to-develop``."""
    import os
    import subprocess

    from koopa.alert import alert, alert_note
    from koopa.git import git_branch
    from koopa.prefix import koopa_prefix

    prefix = koopa_prefix()
    branch = "develop"
    origin = "origin"
    alert(f"Switching koopa at '{prefix}' to '{branch}'.")
    if git_branch(prefix) == branch:
        alert_note(f"Already on '{branch}' branch.")
        return
    subprocess.run(
        ["git", "remote", "set-branches", "--add", origin, branch],
        cwd=prefix, check=True,
    )
    subprocess.run(
        ["git", "fetch", origin],
        cwd=prefix, check=True,
    )
    subprocess.run(
        ["git", "checkout", "--track", f"{origin}/{branch}"],
        cwd=prefix, check=True,
    )
    from koopa.install import _zsh_compaudit_set_permissions
    _zsh_compaudit_set_permissions()


def _handle_disable_passwordless_sudo() -> None:
    """Handle ``koopa system disable-passwordless-sudo``."""
    import grp
    import os

    if os.getuid() != 0:
        msg = "Admin/root access is required."
        raise PermissionError(msg)
    group = "admin" if os.path.exists("/etc/pam.d") else "sudo"
    try:
        grp.getgrnam(group)
    except KeyError:
        group = "sudo"
    sudoers_file = f"/etc/sudoers.d/koopa-{group}"
    if os.path.isfile(sudoers_file):
        print(f"Removing sudo permission file at '{sudoers_file}'.")
        os.remove(sudoers_file)
    print("Passwordless sudo is disabled.")


def _handle_enable_passwordless_sudo() -> None:
    """Handle ``koopa system enable-passwordless-sudo``."""
    import grp
    import os
    import stat

    if os.getuid() != 0:
        msg = "Admin/root access is required."
        raise PermissionError(msg)
    group = "admin" if os.path.exists("/etc/pam.d") else "sudo"
    try:
        grp.getgrnam(group)
    except KeyError:
        group = "sudo"
    sudoers_file = f"/etc/sudoers.d/koopa-{group}"
    if os.path.exists(sudoers_file):
        print(
            f"Passwordless sudo for '{group}' group "
            f"already enabled at '{sudoers_file}'.",
        )
        return
    content = f"%{group} ALL=(ALL:ALL) NOPASSWD:ALL\n"
    print(f"Modifying '{sudoers_file}' to include '{group}'.")
    with open(sudoers_file, "w") as f:
        f.write(content)
    os.chmod(sudoers_file, stat.S_IRUSR | stat.S_IRGRP)
    print(f"Passwordless sudo enabled for '{group}' at '{sudoers_file}'.")


_SYSTEM_COMMANDS: dict[str, str] = {
    "hostname": "hostname",
    "os-string": "os-string",
    "test": "test",
    "zsh-compaudit-set-permissions": "zsh-compaudit-set-permissions",
    "delete-cache": "linux-delete-cache",
    "fix-sudo-setrlimit-error": "linux-fix-sudo-setrlimit-error",
    "spotlight": "macos-spotlight-find",
    "clean-launch-services": "macos-clean-launch-services",
    "create-dmg": "macos-create-dmg",
    "disable-touch-id-sudo": "macos-disable-touch-id-sudo",
    "enable-touch-id-sudo": "macos-enable-touch-id-sudo",
    "flush-dns": "macos-flush-dns",
    "force-eject": "macos-force-eject",
    "ifactive": "macos-ifactive",
    "reload-autofs": "macos-reload-autofs",
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
    if subcmd == "check":
        _handle_check(rest)
        return
    if subcmd == "info":
        _handle_system_info(rest)
        return
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
    if subcmd == "disable-passwordless-sudo":
        _handle_disable_passwordless_sudo()
        return
    if subcmd == "enable-passwordless-sudo":
        _handle_enable_passwordless_sudo()
        return
    if subcmd == "switch-to-develop":
        _handle_switch_to_develop(rest)
        return
    if subcmd == "update-tex-packages":
        _handle_update_tex_packages()
        return
    key = _SYSTEM_COMMANDS.get(subcmd)
    if key is None:
        print(f"Error: unknown system command '{subcmd}'.", file=sys.stderr)
        sys.exit(1)
    _run_bash(key, *rest)
