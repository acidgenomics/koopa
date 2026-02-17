"""Linux-specific system administration functions.

Converted from Bash functions in lang/bash/functions/os/linux/:
user/group management, systemctl, apt/dnf/apk/pacman/zypper package managers,
configure-system-sshd, configure-lmod, etc.
"""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


def _run(
    *args: str,
    sudo: bool = False,
    capture: bool = False,
) -> subprocess.CompletedProcess:
    """Run a command."""
    cmd = list(args)
    if sudo:
        cmd = ["sudo", *cmd]
    return subprocess.run(cmd, capture_output=capture, text=True, check=True)


# -- OS info -----------------------------------------------------------------


def os_version() -> str:
    """Get Linux distribution version."""
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("VERSION_ID="):
                    return line.split("=", 1)[1].strip().strip('"')
    except FileNotFoundError:
        pass
    return ""


def proc_cmdline() -> str:
    """Get /proc/cmdline contents."""
    try:
        return open("/proc/cmdline").read().strip()
    except FileNotFoundError:
        return ""


def is_init_systemd() -> bool:
    """Check if system uses systemd."""
    return os.path.isdir("/run/systemd/system")


# -- User/group management ---------------------------------------------------


def add_user(
    name: str,
    *,
    home: str | None = None,
    shell: str = "/bin/bash",
    system: bool = False,
    sudo_access: bool = False,
) -> None:
    """Add a system user."""
    args = ["useradd"]
    if system:
        args.append("--system")
    if home:
        args.extend(["--home-dir", home, "--create-home"])
    args.extend(["--shell", shell, name])
    _run(*args, sudo=True)
    if sudo_access:
        _run("usermod", "-aG", "sudo", name, sudo=True)


def delete_user(name: str, *, remove_home: bool = False) -> None:
    """Delete a system user."""
    args = ["userdel"]
    if remove_home:
        args.append("--remove")
    args.append(name)
    _run(*args, sudo=True)


def add_group(name: str, *, system: bool = False) -> None:
    """Add a system group."""
    args = ["groupadd"]
    if system:
        args.append("--system")
    args.append(name)
    _run(*args, sudo=True)


def add_user_to_group(user: str, group: str) -> None:
    """Add a user to a group."""
    _run("usermod", "-aG", group, user, sudo=True)


# -- systemctl ---------------------------------------------------------------


def systemctl_start(service: str) -> None:
    """Start a systemd service."""
    _run("systemctl", "start", service, sudo=True)


def systemctl_stop(service: str) -> None:
    """Stop a systemd service."""
    _run("systemctl", "stop", service, sudo=True)


def systemctl_restart(service: str) -> None:
    """Restart a systemd service."""
    _run("systemctl", "restart", service, sudo=True)


def systemctl_enable(service: str) -> None:
    """Enable a systemd service."""
    _run("systemctl", "enable", service, sudo=True)


def systemctl_disable(service: str) -> None:
    """Disable a systemd service."""
    _run("systemctl", "disable", service, sudo=True)


def systemctl_status(service: str) -> str:
    """Get systemd service status."""
    result = subprocess.run(
        ["systemctl", "status", service],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


# -- Package managers --------------------------------------------------------


def apt_install(*packages: str) -> None:
    """Install packages with apt."""
    _run("apt-get", "install", "-y", *packages, sudo=True)


def apt_remove(*packages: str) -> None:
    """Remove packages with apt."""
    _run("apt-get", "remove", "-y", *packages, sudo=True)


def apt_update() -> None:
    """Update apt package lists."""
    _run("apt-get", "update", "-y", sudo=True)


def apt_upgrade() -> None:
    """Upgrade apt packages."""
    _run("apt-get", "upgrade", "-y", sudo=True)


def apt_clean() -> None:
    """Clean apt cache."""
    _run("apt-get", "clean", sudo=True)
    _run("apt-get", "autoremove", "-y", sudo=True)


def apt_list_installed() -> list[str]:
    """List installed apt packages."""
    result = _run("dpkg", "--get-selections", capture=True)
    return [line.split()[0] for line in result.stdout.splitlines() if "install" in line]


def dnf_install(*packages: str) -> None:
    """Install packages with dnf."""
    _run("dnf", "install", "-y", *packages, sudo=True)


def dnf_remove(*packages: str) -> None:
    """Remove packages with dnf."""
    _run("dnf", "remove", "-y", *packages, sudo=True)


def dnf_update() -> None:
    """Update dnf packages."""
    _run("dnf", "update", "-y", sudo=True)


def apk_install(*packages: str) -> None:
    """Install packages with apk (Alpine)."""
    _run("apk", "add", *packages, sudo=True)


def apk_remove(*packages: str) -> None:
    """Remove packages with apk (Alpine)."""
    _run("apk", "del", *packages, sudo=True)


def apk_update() -> None:
    """Update apk package index."""
    _run("apk", "update", sudo=True)


def pacman_install(*packages: str) -> None:
    """Install packages with pacman (Arch)."""
    _run("pacman", "-S", "--noconfirm", *packages, sudo=True)


def pacman_remove(*packages: str) -> None:
    """Remove packages with pacman (Arch)."""
    _run("pacman", "-R", "--noconfirm", *packages, sudo=True)


def pacman_update() -> None:
    """Update pacman packages."""
    _run("pacman", "-Syu", "--noconfirm", sudo=True)


def zypper_install(*packages: str) -> None:
    """Install packages with zypper (openSUSE)."""
    _run("zypper", "install", "-y", *packages, sudo=True)


def zypper_remove(*packages: str) -> None:
    """Remove packages with zypper (openSUSE)."""
    _run("zypper", "remove", "-y", *packages, sudo=True)


def zypper_update() -> None:
    """Update zypper packages."""
    _run("zypper", "update", "-y", sudo=True)


# -- System configuration ----------------------------------------------------


def configure_system_sshd(
    *,
    permit_root_login: str = "no",
    password_auth: str = "no",
    port: int = 22,
) -> None:
    """Configure sshd."""
    config = f"""\
Port {port}
PermitRootLogin {permit_root_login}
PasswordAuthentication {password_auth}
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
"""
    Path("/etc/ssh/sshd_config.d/99-koopa.conf").write_text(config)
    systemctl_restart("sshd")


def configure_lmod(prefix: str) -> None:
    """Configure Lmod environment modules."""
    profile_d = "/etc/profile.d"
    script = os.path.join(profile_d, "z00_lmod.sh")
    content = f"""\
if [ -f "{prefix}/lmod/init/profile" ]; then
    . "{prefix}/lmod/init/profile"
fi
"""
    Path(script).write_text(content)


# -- Install helpers ---------------------------------------------------------

_LINUX_INSTALL_APPS = (
    "build-essential",
    "cmake",
    "curl",
    "git",
    "htop",
    "jq",
    "libcurl4-openssl-dev",
    "libssl-dev",
    "make",
    "neofetch",
    "rsync",
    "shellcheck",
    "tree",
    "unzip",
    "vim",
    "wget",
    "zsh",
)


def install_linux_app(name: str, *, manager: str = "apt") -> None:
    """Install a Linux application using system package manager."""
    managers = {
        "apt": apt_install,
        "dnf": dnf_install,
        "apk": apk_install,
        "pacman": pacman_install,
        "zypper": zypper_install,
    }
    func = managers.get(manager)
    if func is None:
        msg = f"Unsupported package manager: {manager}"
        raise ValueError(msg)
    func(name)


def uninstall_linux_app(name: str, *, manager: str = "apt") -> None:
    """Uninstall a Linux application using system package manager."""
    managers = {
        "apt": apt_remove,
        "dnf": dnf_remove,
        "apk": apk_remove,
        "pacman": pacman_remove,
        "zypper": zypper_remove,
    }
    func = managers.get(manager)
    if func is None:
        msg = f"Unsupported package manager: {manager}"
        raise ValueError(msg)
    func(name)
