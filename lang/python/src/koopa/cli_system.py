"""Dispatch table for ``koopa system`` subcommands.

Replaces the 117-line ``_koopa_cli_system`` Bash function.
"""

from __future__ import annotations

import os
import re
import shutil
import stat
import subprocess
import sys
from pathlib import Path


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


def _handle_list_app_versions(args: list[str]) -> None:
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


def _handle_list_launch_agents(args: list[str]) -> None:
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


def _handle_prune_apps() -> None:
    """Handle ``koopa system prune-apps``."""
    from koopa.app import prune_apps

    prune_apps()


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


def _handle_check(args: list[str]) -> None:
    """Handle ``koopa system check``."""
    from koopa.check import check_system

    if not check_system():
        sys.exit(1)


def _handle_system_info(args: list[str]) -> None:
    """Handle ``koopa system info``."""
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


def _handle_os_string() -> None:
    """Handle ``koopa system os-string``.

    Returns a machine-readable OS identifier like 'macos-15' or 'ubuntu-22'.
    """
    from koopa.system import is_linux, is_macos, macos_os_version, major_version

    os_id = ""
    version = ""
    if is_macos():
        os_id = "macos"
        version = major_version(macos_os_version())
    elif is_linux():
        release_file = Path("/etc/os-release")
        if release_file.is_file():
            content = release_file.read_text()
            id_match = re.search(r'^ID=(.+)$', content, re.MULTILINE)
            if id_match:
                os_id = id_match.group(1).strip('"')
            ver_match = re.search(r'^VERSION_ID=(.+)$', content, re.MULTILINE)
            if ver_match:
                version = major_version(ver_match.group(1).strip('"'))
            else:
                version = "rolling"
        else:
            os_id = "linux"
    if not os_id:
        sys.exit(1)
    result_str = os_id
    if version:
        result_str = f"{os_id}-{version}"
    print(result_str)


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
                f"Changing ownership at '{prefix}' "
                f"from '{st.st_uid}' to '{uid}'.",
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

    is_docker = (
        os.environ.get("KOOPA_IS_DOCKER", "0") == "1"
        or os.path.isfile("/.dockerenv")
    )
    if not is_docker:
        print("Error: Cache removal only supported inside Docker images.",
              file=sys.stderr)
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
                    try:
                        os.remove(path)
                    except OSError:
                        pass
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
                    try:
                        os.remove(path)
                    except OSError:
                        pass


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


def _handle_macos_spotlight_find(args: list[str]) -> None:
    """Handle ``koopa system spotlight <pattern> [dir]``."""
    if not args:
        print("Error: pattern argument is required.", file=sys.stderr)
        sys.exit(1)
    pattern = args[0]
    search_dir = args[1] if len(args) > 1 else "."
    if not os.path.isdir(search_dir):
        print(f"Error: not a directory: '{search_dir}'.", file=sys.stderr)
        sys.exit(1)
    result = subprocess.run(
        ["mdfind", "-name", pattern, "-onlyin", search_dir],
        capture_output=True,
        text=True,
        check=False,
    )
    output = result.stdout.strip()
    if not output:
        sys.exit(1)
    print(output)


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
        [lsregister, "-kill", "-r",
         "-domain", "local", "-domain", "system", "-domain", "user"],
        check=True,
    )
    subprocess.run(
        ["sudo", lsregister, "-kill", "-lint", "-seed", "-f", "-r", "-v",
         "-dump", "-domain", "local", "-domain", "network",
         "-domain", "system", "-domain", "user"],
        check=True,
    )
    subprocess.run(["sudo", killall, "Finder"], check=True)
    subprocess.run(["sudo", killall, "Dock"], check=True)
    alert_success("Clean up was successful.")


def _handle_macos_create_dmg(args: list[str]) -> None:
    """Handle ``koopa system create-dmg <source-folder>``."""
    if len(args) != 1:
        print("Error: exactly one argument (source folder) is required.",
              file=sys.stderr)
        sys.exit(1)
    hdiutil = "/usr/bin/hdiutil"
    if not os.path.isfile(hdiutil):
        print("Error: 'hdiutil' is not installed.", file=sys.stderr)
        sys.exit(1)
    srcfolder = os.path.realpath(args[0])
    if not os.path.isdir(srcfolder):
        print(f"Error: not a directory: '{srcfolder}'.", file=sys.stderr)
        sys.exit(1)
    volname = os.path.basename(srcfolder)
    ov = f"{volname}.dmg"
    subprocess.run(
        [hdiutil, "create", "-ov", ov,
         "-srcfolder", srcfolder, "-volname", volname],
        check=True,
    )


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
        print("Error: exactly one argument (volume name) is required.",
              file=sys.stderr)
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


def _handle_macos_ifactive() -> None:
    """Handle ``koopa system ifactive``."""
    ifconfig = "/sbin/ifconfig"
    pcregrep = shutil.which("pcregrep")
    if not os.path.isfile(ifconfig):
        print("Error: 'ifconfig' is not installed.", file=sys.stderr)
        sys.exit(1)
    if pcregrep is None:
        print("Error: 'pcregrep' is not installed.", file=sys.stderr)
        sys.exit(1)
    ifconfig_result = subprocess.run(
        [ifconfig],
        capture_output=True,
        text=True,
        check=True,
    )
    pcregrep_result = subprocess.run(
        [pcregrep, "-M", "-o", r"^[^\t:]+:([^\n]|\n\t)*status: active"],
        input=ifconfig_result.stdout,
        capture_output=True,
        text=True,
        check=False,
    )
    output = pcregrep_result.stdout.strip()
    if not output:
        sys.exit(1)
    print(output)


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


_SYSTEM_COMMANDS: dict[str, str] = {
    "test": "test",
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
    if subcmd == "hostname":
        _handle_hostname()
        return
    if subcmd == "os-string":
        _handle_os_string()
        return
    if subcmd == "zsh-compaudit-set-permissions":
        _handle_zsh_compaudit_set_permissions()
        return
    if subcmd == "delete-cache":
        _handle_linux_delete_cache()
        return
    if subcmd == "fix-sudo-setrlimit-error":
        _handle_linux_fix_sudo_setrlimit_error()
        return
    if subcmd == "spotlight":
        _handle_macos_spotlight_find(rest)
        return
    if subcmd == "clean-launch-services":
        _handle_macos_clean_launch_services()
        return
    if subcmd == "create-dmg":
        _handle_macos_create_dmg(rest)
        return
    if subcmd == "disable-touch-id-sudo":
        _handle_macos_disable_touch_id_sudo()
        return
    if subcmd == "enable-touch-id-sudo":
        _handle_macos_enable_touch_id_sudo()
        return
    if subcmd == "flush-dns":
        _handle_macos_flush_dns()
        return
    if subcmd == "force-eject":
        _handle_macos_force_eject(rest)
        return
    if subcmd == "ifactive":
        _handle_macos_ifactive()
        return
    if subcmd == "reload-autofs":
        _handle_macos_reload_autofs()
        return
    key = _SYSTEM_COMMANDS.get(subcmd)
    if key is None:
        print(f"Error: unknown system command '{subcmd}'.", file=sys.stderr)
        sys.exit(1)
    _run_bash(key, *rest)
