"""Dispatch table for ``koopa system`` subcommands.

Replaces the 117-line ``_koopa_cli_system`` Bash function.
"""

import contextlib
import os
import re
import shutil
import stat
import subprocess
import sys
from collections.abc import Callable
from pathlib import Path


def _handle_prefix(args: list[str]) -> None:
    """Handle ``koopa system prefix [name]``."""
    import koopa.prefix as pfx

    if not args or args[0] == "koopa":
        print(pfx.koopa_prefix())
        return
    name = args[0]
    func_name = name.replace("-", "_") + "_prefix"
    func = getattr(pfx, func_name, None)
    if func is None:
        print(f"Error: unknown prefix '{name}'.", file=sys.stderr)
        sys.exit(1)
    result = func(*args[1:])
    print(result)


def _handle_version(args: list[str]) -> None:
    """Handle ``koopa system version [cmd]...``.

    Resolves the version of programs by various methods:
    1. Run the command with a version argument and extract version.
    """
    if not args:
        print("Usage: koopa system version <cmd>...", file=sys.stderr)
        sys.exit(1)
    version_arg_overrides: dict[str, str] = {
        "apptainer": "version",
        "docker-credential-pass": "version",
        "go": "version",
        "openssl": "version",
        "rstudio-server": "version",
        "exiftool": "-ver",
        "lua": "-v",
        "openssh": "-V",
        "ssh": "-V",
        "tmux": "-V",
    }
    version_re = re.compile(
        r"(\d+\.\d+(?:\.\d+)?(?:[._-]?(?:alpha|beta|dev|p|patch|pre|rc|post)?"
        r"\.?\d*)?)",
        re.IGNORECASE,
    )
    for cmd_arg in args:
        cmd_path = shutil.which(cmd_arg)
        if cmd_path is None:
            print(
                f"Error: command not found: '{cmd_arg}'.",
                file=sys.stderr,
            )
            sys.exit(1)
        cmd_path = os.path.realpath(cmd_path)
        bn = os.path.basename(cmd_arg)
        version_arg = version_arg_overrides.get(bn, "--version")
        result = subprocess.run(
            [cmd_path, version_arg],
            capture_output=True,
            text=True,
            check=False,
        )
        output = result.stdout + result.stderr
        if not output:
            print(
                f"Error: failed to get version for '{cmd_arg}'.",
                file=sys.stderr,
            )
            sys.exit(1)
        match = version_re.search(output)
        if not match:
            print(
                f"Error: failed to extract version from '{cmd_arg}' output.",
                file=sys.stderr,
            )
            sys.exit(1)
        print(match.group(1))


def _handle_which(args: list[str]) -> None:
    """Handle ``koopa system which [name]...``.

    Resolves command to full real path.
    """
    if not args:
        print("Usage: koopa system which <cmd>...", file=sys.stderr)
        sys.exit(1)
    for cmd in args:
        cmd_path = shutil.which(cmd)
        if cmd_path is None:
            print(
                f"Error: command not found: '{cmd}'.",
                file=sys.stderr,
            )
            sys.exit(1)
        real = os.path.realpath(cmd_path)
        if not os.access(real, os.X_OK):
            print(
                f"Error: not executable: '{real}'.",
                file=sys.stderr,
            )
            sys.exit(1)
        print(real)


def _handle_list(args: list[str]) -> None:
    """Handle ``koopa system list`` subcommands."""
    if not args:
        print("Error: no list subcommand specified.", file=sys.stderr)
        sys.exit(1)
    subcmd = args[0]
    rest = args[1:]
    if subcmd == "app-versions":
        _handle_list_app_versions(rest)
        return
    if subcmd == "launch-agents":
        _handle_list_launch_agents(rest)
        return
    if subcmd == "path-priority":
        _handle_list_path_priority(rest)
        return
    msg = f"Unknown list subcommand: '{subcmd}'."
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)


def _handle_list_app_versions(_args: list[str]) -> None:
    """Handle ``koopa system list app-versions``.

    Lists installed app versions from app prefix directories.
    """
    from koopa.prefix import app_prefix

    prefix = app_prefix()
    if not os.path.isdir(prefix):
        from koopa.alert import alert_note

        alert_note(f"No apps are installed in '{prefix}'.")
        return
    results: list[str] = []
    try:
        app_dirs = sorted(os.listdir(prefix))
    except OSError:
        app_dirs = []
    for app_name in app_dirs:
        app_path = os.path.join(prefix, app_name)
        if not os.path.isdir(app_path):
            continue
        try:
            versions = sorted(os.listdir(app_path))
        except OSError:
            continue
        for ver in versions:
            ver_path = os.path.join(app_path, ver)
            if os.path.isdir(ver_path):
                results.append(ver_path)
    if not results:
        sys.exit(1)
    for r in results:
        print(r)


def _handle_list_launch_agents(_args: list[str]) -> None:
    """Handle ``koopa system list launch-agents``.

    Lists files in LaunchAgents/LaunchDaemons directories (macOS).
    """
    from koopa.system import is_macos

    if not is_macos():
        print("Error: this command is only available on macOS.", file=sys.stderr)
        sys.exit(1)
    dirs = [
        os.path.expanduser("~/Library/LaunchAgents"),
        "/Library/LaunchAgents",
        "/Library/LaunchDaemons",
        "/Library/PrivilegedHelperTools",
    ]
    for d in dirs:
        if not os.path.isdir(d):
            continue
        try:
            entries = sorted(os.listdir(d))
        except OSError:
            continue
        entries = [e for e in entries if e != "disabled"]
        if entries:
            print(f"\n{d}:")
            for entry in entries:
                print(entry)


def _handle_list_path_priority(args: list[str]) -> None:
    """Handle ``koopa system list path-priority``.

    Splits $PATH, deduplicates, and reports duplicates.
    """
    path_str = args[0] if args else os.environ.get("PATH", "")
    all_dirs = path_str.split(":")
    all_dirs = [d for d in all_dirs if d]
    if not all_dirs:
        sys.exit(1)
    seen: set[str] = set()
    unique: list[str] = []
    for d in all_dirs:
        if d not in seen:
            seen.add(d)
            unique.append(d)
    n_all = len(all_dirs)
    n_unique = len(unique)
    n_dupes = n_all - n_unique
    if n_dupes > 0:
        suffix = "duplicate" if n_dupes == 1 else "duplicates"
        from koopa.alert import alert_note

        alert_note(f"{n_dupes} {suffix} detected.")
    for d in all_dirs:
        print(d)


def _handle_prune_apps(args: list[str] | None = None) -> None:
    """Handle ``koopa system prune-apps``."""
    from koopa.app import prune_apps

    verbose = args is not None and "--verbose" in args
    prune_apps(verbose=verbose)


def _handle_update_tex_packages() -> None:
    """Handle ``koopa system update-tex-packages``."""
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


def _handle_check(_args: list[str]) -> None:
    """Handle ``koopa system check``."""
    from koopa.check import check_system
    from koopa.install import _install_lock_path

    lock_path = _install_lock_path()
    if os.path.isfile(lock_path):
        try:
            pid = int(Path(lock_path).read_text().strip())
            os.kill(pid, 0)
            from koopa.alert import alert_note

            alert_note(
                f"Skipping system check: install in progress (PID {pid}).\n"
                f"If this is a stale lock, remove it with:\n"
                f"  rm '{lock_path}'"
            )
            return
        except (ValueError, ProcessLookupError, OSError):
            pass
    if not check_system():
        sys.exit(1)


def _parse_os_release(path: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    with open(path) as f:
        for line in f:
            stripped = line.strip()
            if "=" in stripped and not stripped.startswith("#"):
                key, _, value = stripped.partition("=")
                fields[key.strip()] = value.strip().strip('"')
    return fields


def _get_linux_distro() -> str:
    if os.path.isfile("/etc/os-release"):
        fields = _parse_os_release("/etc/os-release")
        name = fields.get("NAME", "")
        version = fields.get("VERSION_ID", "")
        return f"{name} {version}".strip() if name else "Linux"
    if os.path.isfile("/etc/redhat-release"):
        with open("/etc/redhat-release") as f:
            return f.read().strip()
    return "Linux"


def _get_glibc_version() -> str:
    import platform

    lib, version = platform.libc_ver()
    if lib and version:
        return f"{lib} {version}"
    try:
        result = subprocess.run(
            ["ldd", "--version"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        if result.stdout:
            return result.stdout.splitlines()[0]
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return "unknown"


def _handle_system_info(_args: list[str]) -> None:
    """Handle ``koopa system info``."""
    import platform

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
        info.extend(
            [
                "",
                "Git repo",
                "--------",
                f"Remote: {git_remote_url(prefix)}",
                f"Commit: {git_last_commit_local(prefix)}",
                f"Date: {git_commit_date(prefix)}",
            ]
        )
    bash = shutil.which("bash")
    bash_ver = ""
    if bash:
        bash = os.path.realpath(bash)
        result = subprocess.run(
            [bash, "--version"],
            capture_output=True,
            text=True,
            check=False,
        )
        first_line = result.stdout.strip().splitlines()[0] if result.stdout else ""
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
            capture_output=True,
            text=True,
            check=False,
        )
        os_str = " ".join(result.stdout.split()) if result.stdout else "macOS"
        sys_info_extra: list[str] = []
    else:
        uname = platform.uname()
        os_str = f"{uname.system} {uname.release} {uname.version} {uname.machine}".strip()
        distro_str = _get_linux_distro()
        glibc_str = _get_glibc_version()
        sys_info_extra = [
            f"Distro: {distro_str}",
            f"glibc: {glibc_str}",
        ]
    info.extend(
        [
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
            *sys_info_extra,
            f"Bash: {bash or 'not found'}",
            f"Bash Version: {bash_ver}",
            f"Python: {python or 'not found'}",
            f"Python Version: {python_ver}",
        ]
    )
    neofetch = shutil.which("neofetch")
    if neofetch:
        result = subprocess.run(
            [neofetch, "--stdout"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.stdout:
            nf_lines = result.stdout.strip().splitlines()
            info.extend(["", "Neofetch", "--------", *nf_lines[2:]])
    turtle_file = os.path.join(prefix, "etc", "koopa", "ascii-turtle.txt")
    if os.path.isfile(turtle_file):
        with open(turtle_file) as f:
            print(f.read(), end="")
    print("\n".join(info))


def _handle_switch_to_develop(_args: list[str]) -> None:
    """Handle ``koopa system switch-to-develop``."""
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
        cwd=prefix,
        check=True,
    )
    subprocess.run(
        ["git", "fetch", origin],
        cwd=prefix,
        check=True,
    )
    subprocess.run(
        ["git", "checkout", "--track", f"{origin}/{branch}"],
        cwd=prefix,
        check=True,
    )
    from koopa.install import _zsh_compaudit_set_permissions

    _zsh_compaudit_set_permissions()


def _handle_disable_passwordless_sudo() -> None:
    """Handle ``koopa system disable-passwordless-sudo``."""
    import grp

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
            f"Passwordless sudo for '{group}' group already enabled at '{sudoers_file}'.",
        )
        return
    content = f"%{group} ALL=(ALL:ALL) NOPASSWD:ALL\n"
    print(f"Modifying '{sudoers_file}' to include '{group}'.")
    with open(sudoers_file, "w") as f:
        f.write(content)
    os.chmod(sudoers_file, stat.S_IRUSR | stat.S_IRGRP)
    print(f"Passwordless sudo enabled for '{group}' at '{sudoers_file}'.")


def _handle_hostname() -> None:
    """Handle ``koopa system hostname``."""
    result = subprocess.run(
        ["uname", "-n"],
        capture_output=True,
        text=True,
        check=True,
    )
    hostname = result.stdout.strip()
    if not hostname:
        sys.exit(1)
    print(hostname)


def _handle_os_slug() -> None:
    """Handle ``koopa system os-slug``."""
    from koopa.system import os_slug

    print(os_slug())


def _handle_zsh_compaudit_set_permissions() -> None:
    """Handle ``koopa system zsh-compaudit-set-permissions``."""
    from koopa.alert import alert
    from koopa.prefix import koopa_prefix, opt_prefix

    uid = os.getuid()
    prefixes = [
        os.path.join(koopa_prefix(), "lang", "zsh"),
        os.path.join(opt_prefix(), "zsh", "share", "zsh"),
    ]
    for prefix in prefixes:
        if not os.path.isdir(prefix):
            continue
        st = os.stat(prefix)
        if st.st_uid != uid:
            alert(
                f"Changing ownership at '{prefix}' from '{st.st_uid}' to '{uid}'.",
            )
            subprocess.run(
                ["sudo", "chown", "-R", str(uid), prefix],
                check=True,
            )
        mode = stat.S_IMODE(st.st_mode)
        access = oct(mode)[-3:]
        if access not in ("700", "744", "755"):
            alert(f"Fixing write access at '{prefix}'.")
            subprocess.run(
                ["chmod", "-Rv", "go-w", prefix],
                check=True,
            )


def _handle_linux_delete_cache() -> None:
    """Handle ``koopa system delete-cache``."""
    from koopa.alert import alert

    is_docker = os.environ.get("KOOPA_IS_DOCKER", "0") == "1" or os.path.isfile("/.dockerenv")
    if not is_docker:
        print("Error: Cache removal only supported inside Docker images.", file=sys.stderr)
        sys.exit(1)
    alert("Removing caches, logs, and temporary files.")
    dirs_to_remove = [
        "/root/.cache",
        "/tmp",
        "/var/backups",
        "/var/cache",
    ]
    for d in dirs_to_remove:
        if os.path.isdir(d):
            for entry in os.listdir(d):
                path = os.path.join(d, entry)
                if os.path.isdir(path):
                    shutil.rmtree(path, ignore_errors=True)
                else:
                    with contextlib.suppress(OSError):
                        os.remove(path)
    # Debian-specific apt cleanup.
    from koopa.system import is_debian_like

    if is_debian_like():
        apt_lists = "/var/lib/apt/lists"
        if os.path.isdir(apt_lists):
            for entry in os.listdir(apt_lists):
                path = os.path.join(apt_lists, entry)
                if os.path.isdir(path):
                    shutil.rmtree(path, ignore_errors=True)
                else:
                    with contextlib.suppress(OSError):
                        os.remove(path)


def _handle_linux_fix_sudo_setrlimit_error() -> None:
    """Handle ``koopa system fix-sudo-setrlimit-error``.

    Appends 'Set disable_coredump false' to /etc/sudo.conf.
    """
    conf_file = "/etc/sudo.conf"
    line = "Set disable_coredump false"
    # Check if already present.
    if os.path.isfile(conf_file):
        content = Path(conf_file).read_text()
        if line in content:
            return
    # Append with sudo.
    subprocess.run(
        ["sudo", "tee", "-a", conf_file],
        input=line + "\n",
        capture_output=True,
        text=True,
        check=True,
    )


def _handle_macos_clean_launch_services() -> None:
    """Handle ``koopa system clean-launch-services``."""
    from koopa.alert import alert, alert_success
    from koopa.system import is_admin

    if not is_admin():
        print("Error: Admin access is required.", file=sys.stderr)
        sys.exit(1)
    lsregister = (
        "/System/Library/Frameworks/CoreServices.framework"
        "/Frameworks/LaunchServices.framework/Support/lsregister"
    )
    killall = "/usr/bin/killall"
    for app in (lsregister, killall):
        if not os.path.isfile(app):
            print(f"Error: '{app}' is not installed.", file=sys.stderr)
            sys.exit(1)
    alert("Cleaning LaunchServices 'Open With' menu.")
    subprocess.run(
        [lsregister, "-kill", "-r", "-domain", "local", "-domain", "system", "-domain", "user"],
        check=True,
    )
    subprocess.run(
        [
            "sudo",
            lsregister,
            "-kill",
            "-lint",
            "-seed",
            "-f",
            "-r",
            "-v",
            "-dump",
            "-domain",
            "local",
            "-domain",
            "network",
            "-domain",
            "system",
            "-domain",
            "user",
        ],
        check=True,
    )
    subprocess.run(["sudo", killall, "Finder"], check=True)
    subprocess.run(["sudo", killall, "Dock"], check=True)
    alert_success("Clean up was successful.")


def _handle_macos_disable_touch_id_sudo() -> None:
    """Handle ``koopa system disable-touch-id-sudo``."""
    from koopa.alert import alert, alert_note, alert_success
    from koopa.system import is_admin

    if not is_admin():
        print("Error: Admin access is required.", file=sys.stderr)
        sys.exit(1)
    pam_file = "/etc/pam.d/sudo"
    if os.path.isfile(pam_file):
        content = Path(pam_file).read_text()
        if "pam_tid.so" not in content:
            alert_note(f"Touch ID not enabled in '{pam_file}'.")
            return
    else:
        alert_note(f"PAM file '{pam_file}' does not exist.")
        return
    alert(f"Disabling Touch ID defined in '{pam_file}'.")
    new_content = """\
# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
"""
    subprocess.run(
        ["sudo", "tee", pam_file],
        input=new_content,
        capture_output=True,
        text=True,
        check=True,
    )
    subprocess.run(["sudo", "chmod", "0444", pam_file], check=True)
    alert_success("Touch ID disabled for sudo.")


def _handle_macos_enable_touch_id_sudo() -> None:
    """Handle ``koopa system enable-touch-id-sudo``."""
    from koopa.alert import alert, alert_note, alert_success
    from koopa.system import is_admin

    if not is_admin():
        print("Error: Admin access is required.", file=sys.stderr)
        sys.exit(1)
    pam_file = "/etc/pam.d/sudo"
    if os.path.isfile(pam_file):
        content = Path(pam_file).read_text()
        if "pam_tid.so" in content:
            alert_note(f"Touch ID already enabled in '{pam_file}'.")
            return
    chflags = "/usr/bin/chflags"
    alert(f"Enabling Touch ID in '{pam_file}'.")
    new_content = """\
# sudo: auth account password session
auth       sufficient     pam_tid.so
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
"""
    subprocess.run(["sudo", chflags, "noschg", pam_file], check=True)
    subprocess.run(
        ["sudo", "tee", pam_file],
        input=new_content,
        capture_output=True,
        text=True,
        check=True,
    )
    subprocess.run(["sudo", "chmod", "0444", pam_file], check=True)
    subprocess.run(["sudo", chflags, "schg", pam_file], check=True)
    alert_success("Touch ID enabled for sudo.")


def _handle_macos_flush_dns() -> None:
    """Handle ``koopa system flush-dns``."""
    from koopa.alert import alert, alert_success
    from koopa.system import is_admin

    if not is_admin():
        print("Error: Admin access is required.", file=sys.stderr)
        sys.exit(1)
    dscacheutil = "/usr/bin/dscacheutil"
    killall = "/usr/bin/killall"
    for app in (dscacheutil, killall):
        if not os.path.isfile(app):
            print(f"Error: '{app}' is not installed.", file=sys.stderr)
            sys.exit(1)
    alert("Flushing DNS.")
    subprocess.run(["sudo", dscacheutil, "-flushcache"], check=True)
    subprocess.run(["sudo", killall, "-HUP", "mDNSResponder"], check=True)
    alert_success("DNS flush was successful.")


def _handle_macos_force_eject(args: list[str]) -> None:
    """Handle ``koopa system force-eject <volume-name>``."""
    from koopa.system import is_admin

    if not is_admin():
        print("Error: Admin access is required.", file=sys.stderr)
        sys.exit(1)
    if len(args) != 1:
        print("Error: exactly one argument (volume name) is required.", file=sys.stderr)
        sys.exit(1)
    diskutil = "/usr/sbin/diskutil"
    if not os.path.isfile(diskutil):
        print("Error: 'diskutil' is not installed.", file=sys.stderr)
        sys.exit(1)
    name = args[0]
    mount_point = f"/Volumes/{name}"
    if not os.path.isdir(mount_point):
        print(f"Error: not a directory: '{mount_point}'.", file=sys.stderr)
        sys.exit(1)
    subprocess.run(
        ["sudo", diskutil, "unmount", "force", mount_point],
        check=True,
    )


def _handle_macos_reload_autofs() -> None:
    """Handle ``koopa system reload-autofs``."""
    from koopa.system import is_admin

    if not is_admin():
        print("Error: Admin access is required.", file=sys.stderr)
        sys.exit(1)
    automount = "/usr/sbin/automount"
    if not os.path.isfile(automount):
        print("Error: 'automount' is not installed.", file=sys.stderr)
        sys.exit(1)
    subprocess.run(["sudo", automount, "-vc"], check=True)


_DEFUNCT_COMMANDS: dict[str, str] = {
    "cache-functions": "koopa develop cache-functions",
    "edit-app-json": "koopa develop edit-app-json",
    "prune-app-binaries": "koopa develop prune-app-binaries",
}

_LINUX_ADMIN_COMMANDS: set[str] = {
    "add-group",
    "add-user",
    "apk-install",
    "apk-remove",
    "apk-update",
    "apt-install",
    "apt-list-installed",
    "apt-remove",
    "apt-update",
    "apt-upgrade",
    "configure-lmod",
    "configure-sshd",
    "delete-cache",
    "delete-user",
    "dnf-install",
    "dnf-remove",
    "dnf-update",
    "fix-sudo-setrlimit-error",
    "install-app",
    "os-version",
    "pacman-install",
    "pacman-remove",
    "pacman-update",
    "proc-cmdline",
    "systemctl-disable",
    "systemctl-restart",
    "systemctl-status",
    "systemctl-stop",
    "uninstall-app",
    "zypper-install",
    "zypper-remove",
    "zypper-update",
}

_MACOS_ADMIN_COMMANDS: set[str] = {
    "clean-launch-services",
    "disable-touch-id-sudo",
    "enable-touch-id-sudo",
    "flush-dns",
    "force-eject",
    "reload-autofs",
}


def handle_system(remainder: list[str]) -> None:  # noqa: PLR0911
    """Dispatch ``koopa system ...`` commands."""
    if not remainder:
        print("Error: no system command specified.", file=sys.stderr)
        sys.exit(1)
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
        _handle_prune_apps(rest)
        return
    if subcmd == "switch-to-develop":
        _handle_switch_to_develop(rest)
        return
    if subcmd == "hostname":
        _handle_hostname()
        return
    if subcmd == "os-slug":
        _handle_os_slug()
        return
    print(f"Error: unknown system command '{subcmd}'.", file=sys.stderr)
    sys.exit(1)


def _handle_add_user(args: list[str]) -> None:
    """Handle ``koopa admin add-user``."""
    from koopa.os_linux import add_user

    if not args:
        print(
            "Usage: koopa admin add-user <name> [--home DIR] [--shell SHELL] [--system] [--sudo]",
            file=sys.stderr,
        )
        sys.exit(1)
    name = args[0]
    home = None
    shell = "/bin/bash"
    system = False
    sudo_access = False
    i = 1
    while i < len(args):
        if args[i] == "--home" and i + 1 < len(args):
            home = args[i + 1]
            i += 2
        elif args[i] == "--shell" and i + 1 < len(args):
            shell = args[i + 1]
            i += 2
        elif args[i] == "--system":
            system = True
            i += 1
        elif args[i] == "--sudo":
            sudo_access = True
            i += 1
        else:
            print(f"Error: unknown option '{args[i]}'.", file=sys.stderr)
            sys.exit(1)
    add_user(name, home=home, shell=shell, system=system, sudo_access=sudo_access)


def _handle_delete_user(args: list[str]) -> None:
    """Handle ``koopa admin delete-user``."""
    from koopa.os_linux import delete_user

    if not args:
        print("Usage: koopa admin delete-user <name> [--remove-home]", file=sys.stderr)
        sys.exit(1)
    name = args[0]
    remove_home = "--remove-home" in args[1:]
    delete_user(name, remove_home=remove_home)


def _handle_add_group(args: list[str]) -> None:
    """Handle ``koopa admin add-group``."""
    from koopa.os_linux import add_group

    if not args:
        print("Usage: koopa admin add-group <name> [--system]", file=sys.stderr)
        sys.exit(1)
    name = args[0]
    system = "--system" in args[1:]
    add_group(name, system=system)


def _handle_systemctl_stop(args: list[str]) -> None:
    """Handle ``koopa admin systemctl-stop``."""
    from koopa.os_linux import systemctl_stop

    if not args:
        print("Usage: koopa admin systemctl-stop <service>", file=sys.stderr)
        sys.exit(1)
    systemctl_stop(args[0])


def _handle_systemctl_restart(args: list[str]) -> None:
    """Handle ``koopa admin systemctl-restart``."""
    from koopa.os_linux import systemctl_restart

    if not args:
        print("Usage: koopa admin systemctl-restart <service>", file=sys.stderr)
        sys.exit(1)
    systemctl_restart(args[0])


def _handle_systemctl_disable(args: list[str]) -> None:
    """Handle ``koopa admin systemctl-disable``."""
    from koopa.os_linux import systemctl_disable

    if not args:
        print("Usage: koopa admin systemctl-disable <service>", file=sys.stderr)
        sys.exit(1)
    systemctl_disable(args[0])


def _handle_systemctl_status(args: list[str]) -> None:
    """Handle ``koopa admin systemctl-status``."""
    from koopa.os_linux import systemctl_status

    if not args:
        print("Usage: koopa admin systemctl-status <service>", file=sys.stderr)
        sys.exit(1)
    print(systemctl_status(args[0]))


def _handle_configure_sshd(args: list[str]) -> None:
    """Handle ``koopa admin configure-sshd``."""
    from koopa.os_linux import configure_system_sshd

    port = 22
    permit_root_login = "no"
    password_auth = "no"
    i = 0
    while i < len(args):
        if args[i] == "--port" and i + 1 < len(args):
            port = int(args[i + 1])
            i += 2
        elif args[i] == "--permit-root-login" and i + 1 < len(args):
            permit_root_login = args[i + 1]
            i += 2
        elif args[i] == "--password-auth" and i + 1 < len(args):
            password_auth = args[i + 1]
            i += 2
        else:
            print(f"Error: unknown option '{args[i]}'.", file=sys.stderr)
            sys.exit(1)
    configure_system_sshd(
        port=port,
        permit_root_login=permit_root_login,
        password_auth=password_auth,
    )


def _handle_configure_lmod(args: list[str]) -> None:
    """Handle ``koopa admin configure-lmod``."""
    from koopa.os_linux import configure_lmod

    if not args:
        print("Usage: koopa admin configure-lmod <prefix>", file=sys.stderr)
        sys.exit(1)
    configure_lmod(args[0])


def _handle_install_app(args: list[str]) -> None:
    """Handle ``koopa admin install-app``."""
    from koopa.os_linux import install_linux_app

    if not args:
        print(
            "Usage: koopa admin install-app <name> [--manager apt|dnf|apk|pacman|zypper]",
            file=sys.stderr,
        )
        sys.exit(1)
    name = args[0]
    manager = "apt"
    if "--manager" in args[1:]:
        idx = args.index("--manager")
        if idx + 1 < len(args):
            manager = args[idx + 1]
    install_linux_app(name, manager=manager)


def _handle_uninstall_app(args: list[str]) -> None:
    """Handle ``koopa admin uninstall-app``."""
    from koopa.os_linux import uninstall_linux_app

    if not args:
        print(
            "Usage: koopa admin uninstall-app <name> [--manager apt|dnf|apk|pacman|zypper]",
            file=sys.stderr,
        )
        sys.exit(1)
    name = args[0]
    manager = "apt"
    if "--manager" in args[1:]:
        idx = args.index("--manager")
        if idx + 1 < len(args):
            manager = args[idx + 1]
    uninstall_linux_app(name, manager=manager)


def _handle_os_version(_args: list[str]) -> None:
    """Handle ``koopa admin os-version``."""
    from koopa.os_linux import os_version

    print(os_version())


def _handle_proc_cmdline(_args: list[str]) -> None:
    """Handle ``koopa admin proc-cmdline``."""
    from koopa.os_linux import proc_cmdline

    print(proc_cmdline())


def _handle_apt_install(args: list[str]) -> None:
    """Handle ``koopa admin apt-install``."""
    from koopa.os_linux import apt_install

    if not args:
        print("Usage: koopa admin apt-install <packages...>", file=sys.stderr)
        sys.exit(1)
    apt_install(*args)


def _handle_apt_remove(args: list[str]) -> None:
    """Handle ``koopa admin apt-remove``."""
    from koopa.os_linux import apt_remove

    if not args:
        print("Usage: koopa admin apt-remove <packages...>", file=sys.stderr)
        sys.exit(1)
    apt_remove(*args)


def _handle_apt_update(_args: list[str]) -> None:
    """Handle ``koopa admin apt-update``."""
    from koopa.os_linux import apt_update

    apt_update()


def _handle_apt_upgrade(_args: list[str]) -> None:
    """Handle ``koopa admin apt-upgrade``."""
    from koopa.os_linux import apt_upgrade

    apt_upgrade()


def _handle_apt_list_installed(_args: list[str]) -> None:
    """Handle ``koopa admin apt-list-installed``."""
    from koopa.os_linux import apt_list_installed

    for pkg in apt_list_installed():
        print(pkg)


def _handle_dnf_install(args: list[str]) -> None:
    """Handle ``koopa admin dnf-install``."""
    from koopa.os_linux import dnf_install

    if not args:
        print("Usage: koopa admin dnf-install <packages...>", file=sys.stderr)
        sys.exit(1)
    dnf_install(*args)


def _handle_dnf_remove(args: list[str]) -> None:
    """Handle ``koopa admin dnf-remove``."""
    from koopa.os_linux import dnf_remove

    if not args:
        print("Usage: koopa admin dnf-remove <packages...>", file=sys.stderr)
        sys.exit(1)
    dnf_remove(*args)


def _handle_dnf_update(_args: list[str]) -> None:
    """Handle ``koopa admin dnf-update``."""
    from koopa.os_linux import dnf_update

    dnf_update()


def _handle_apk_install(args: list[str]) -> None:
    """Handle ``koopa admin apk-install``."""
    from koopa.os_linux import apk_install

    if not args:
        print("Usage: koopa admin apk-install <packages...>", file=sys.stderr)
        sys.exit(1)
    apk_install(*args)


def _handle_apk_remove(args: list[str]) -> None:
    """Handle ``koopa admin apk-remove``."""
    from koopa.os_linux import apk_remove

    if not args:
        print("Usage: koopa admin apk-remove <packages...>", file=sys.stderr)
        sys.exit(1)
    apk_remove(*args)


def _handle_apk_update(_args: list[str]) -> None:
    """Handle ``koopa admin apk-update``."""
    from koopa.os_linux import apk_update

    apk_update()


def _handle_pacman_install(args: list[str]) -> None:
    """Handle ``koopa admin pacman-install``."""
    from koopa.os_linux import pacman_install

    if not args:
        print("Usage: koopa admin pacman-install <packages...>", file=sys.stderr)
        sys.exit(1)
    pacman_install(*args)


def _handle_pacman_remove(args: list[str]) -> None:
    """Handle ``koopa admin pacman-remove``."""
    from koopa.os_linux import pacman_remove

    if not args:
        print("Usage: koopa admin pacman-remove <packages...>", file=sys.stderr)
        sys.exit(1)
    pacman_remove(*args)


def _handle_pacman_update(_args: list[str]) -> None:
    """Handle ``koopa admin pacman-update``."""
    from koopa.os_linux import pacman_update

    pacman_update()


def _handle_zypper_install(args: list[str]) -> None:
    """Handle ``koopa admin zypper-install``."""
    from koopa.os_linux import zypper_install

    if not args:
        print("Usage: koopa admin zypper-install <packages...>", file=sys.stderr)
        sys.exit(1)
    zypper_install(*args)


def _handle_zypper_remove(args: list[str]) -> None:
    """Handle ``koopa admin zypper-remove``."""
    from koopa.os_linux import zypper_remove

    if not args:
        print("Usage: koopa admin zypper-remove <packages...>", file=sys.stderr)
        sys.exit(1)
    zypper_remove(*args)


def _handle_zypper_update(_args: list[str]) -> None:
    """Handle ``koopa admin zypper-update``."""
    from koopa.os_linux import zypper_update

    zypper_update()


_ADMIN_HANDLERS: dict[str, Callable[[list[str]], None]] = {
    "add-group": _handle_add_group,
    "add-user": _handle_add_user,
    "apk-install": _handle_apk_install,
    "apk-remove": _handle_apk_remove,
    "apk-update": _handle_apk_update,
    "apt-install": _handle_apt_install,
    "apt-list-installed": _handle_apt_list_installed,
    "apt-remove": _handle_apt_remove,
    "apt-update": _handle_apt_update,
    "apt-upgrade": _handle_apt_upgrade,
    "clean-launch-services": lambda _: _handle_macos_clean_launch_services(),
    "configure-lmod": _handle_configure_lmod,
    "configure-sshd": _handle_configure_sshd,
    "delete-cache": lambda _: _handle_linux_delete_cache(),
    "delete-user": _handle_delete_user,
    "disable-passwordless-sudo": lambda _: _handle_disable_passwordless_sudo(),
    "disable-touch-id-sudo": lambda _: _handle_macos_disable_touch_id_sudo(),
    "dnf-install": _handle_dnf_install,
    "dnf-remove": _handle_dnf_remove,
    "dnf-update": _handle_dnf_update,
    "enable-passwordless-sudo": lambda _: _handle_enable_passwordless_sudo(),
    "enable-touch-id-sudo": lambda _: _handle_macos_enable_touch_id_sudo(),
    "fix-sudo-setrlimit-error": lambda _: _handle_linux_fix_sudo_setrlimit_error(),
    "flush-dns": lambda _: _handle_macos_flush_dns(),
    "force-eject": _handle_macos_force_eject,
    "install-app": _handle_install_app,
    "os-version": _handle_os_version,
    "pacman-install": _handle_pacman_install,
    "pacman-remove": _handle_pacman_remove,
    "pacman-update": _handle_pacman_update,
    "proc-cmdline": _handle_proc_cmdline,
    "reload-autofs": lambda _: _handle_macos_reload_autofs(),
    "systemctl-disable": _handle_systemctl_disable,
    "systemctl-restart": _handle_systemctl_restart,
    "systemctl-status": _handle_systemctl_status,
    "systemctl-stop": _handle_systemctl_stop,
    "uninstall-app": _handle_uninstall_app,
    "zypper-install": _handle_zypper_install,
    "zypper-remove": _handle_zypper_remove,
    "zypper-update": _handle_zypper_update,
    "zsh-compaudit-set-permissions": lambda _: _handle_zsh_compaudit_set_permissions(),
}


def handle_admin(remainder: list[str]) -> None:
    """Dispatch ``koopa admin ...`` commands (require sudo/admin)."""
    from koopa.system import is_linux, is_macos

    if not remainder:
        print("Error: no admin command specified.", file=sys.stderr)
        sys.exit(1)
    subcmd = remainder[0]
    rest = remainder[1:]
    if subcmd in _LINUX_ADMIN_COMMANDS and not is_linux():
        print(f"Error: '{subcmd}' is only supported on Linux.", file=sys.stderr)
        sys.exit(1)
    if subcmd in _MACOS_ADMIN_COMMANDS and not is_macos():
        print(f"Error: '{subcmd}' is only supported on macOS.", file=sys.stderr)
        sys.exit(1)
    handler = _ADMIN_HANDLERS.get(subcmd)
    if handler is None:
        print(f"Error: unknown admin command '{subcmd}'.", file=sys.stderr)
        sys.exit(1)
    handler(rest)
