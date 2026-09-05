"""Linux-specific system administration functions.

Converted from Bash functions in lang/bash/functions/os/linux/:
user/group management, systemctl, apt/dnf/apk/pacman/zypper package managers,
configure-system-sshd, configure-lmod, etc.
"""

import os
from pathlib import Path

from koopa.exec import run

# -- OS info -----------------------------------------------------------------


def os_version() -> str:
    """Get Linux distribution version.

    Returns
    -------
    str
        Value of ``VERSION_ID`` from ``/etc/os-release``, or an empty string
        if the file is missing or the field is not set.
    """
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("VERSION_ID="):
                    return line.split("=", 1)[1].strip().strip('"')
    except FileNotFoundError:
        pass
    return ""


def proc_cmdline() -> str:
    """Get /proc/cmdline contents.

    Returns
    -------
    str
        Contents of ``/proc/cmdline``, or an empty string if the file is
        missing.
    """
    try:
        return open("/proc/cmdline").read().strip()
    except FileNotFoundError:
        return ""


def is_init_systemd() -> bool:
    """Check if system uses systemd.

    Returns
    -------
    bool
        True if ``/run/systemd/system`` exists.
    """
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
    """Add a system user.

    Parameters
    ----------
    name : str
        User name to create.
    home : str | None, optional
        Home directory path. Created along with the user if given.
    shell : str, optional
        Login shell path.
    system : bool, optional
        Create a system account instead of a normal user account.
    sudo_access : bool, optional
        Add the new user to the ``sudo`` group.
    """
    args = ["useradd"]
    if system:
        args.append("--system")
    if home:
        args.extend(["--home-dir", home, "--create-home"])
    args.extend(["--shell", shell, name])
    run(*args, sudo=True)
    if sudo_access:
        run("usermod", "-aG", "sudo", name, sudo=True)


def delete_user(name: str, *, remove_home: bool = False) -> None:
    """Delete a system user.

    Parameters
    ----------
    name : str
        User name to delete.
    remove_home : bool, optional
        Also remove the user's home directory.
    """
    args = ["userdel"]
    if remove_home:
        args.append("--remove")
    args.append(name)
    run(*args, sudo=True)


def add_group(name: str, *, system: bool = False) -> None:
    """Add a system group.

    Parameters
    ----------
    name : str
        Group name to create.
    system : bool, optional
        Create a system group instead of a normal group.
    """
    args = ["groupadd"]
    if system:
        args.append("--system")
    args.append(name)
    run(*args, sudo=True)


def add_user_to_group(user: str, group: str) -> None:
    """Add a user to a group.

    Parameters
    ----------
    user : str
        User name to add.
    group : str
        Group name to add the user to.
    """
    run("usermod", "-aG", group, user, sudo=True)


# -- systemctl ---------------------------------------------------------------


def systemctl_start(service: str) -> None:
    """Start a systemd service.

    Parameters
    ----------
    service : str
        Name of the systemd service to start.
    """
    run("systemctl", "start", service, sudo=True)


def systemctl_stop(service: str) -> None:
    """Stop a systemd service.

    Parameters
    ----------
    service : str
        Name of the systemd service to stop.
    """
    run("systemctl", "stop", service, sudo=True)


def systemctl_restart(service: str) -> None:
    """Restart a systemd service.

    Parameters
    ----------
    service : str
        Name of the systemd service to restart.
    """
    run("systemctl", "restart", service, sudo=True)


def systemctl_enable(service: str) -> None:
    """Enable a systemd service.

    Parameters
    ----------
    service : str
        Name of the systemd service to enable.
    """
    run("systemctl", "enable", service, sudo=True)


def systemctl_disable(service: str) -> None:
    """Disable a systemd service.

    Parameters
    ----------
    service : str
        Name of the systemd service to disable.
    """
    run("systemctl", "disable", service, sudo=True)


def systemctl_status(service: str) -> str:
    """Get systemd service status.

    Parameters
    ----------
    service : str
        Name of the systemd service to query.

    Returns
    -------
    str
        Standard output of ``systemctl status``.
    """
    result = run("systemctl", "status", service, capture=True)
    return result.stdout


# -- Package managers --------------------------------------------------------


def apt_install(*packages: str) -> None:
    """Install packages with apt.

    Parameters
    ----------
    *packages : str
        Names of apt packages to install.
    """
    run("apt-get", "install", "-y", *packages, sudo=True)


def apt_remove(*packages: str) -> None:
    """Remove packages with apt.

    Parameters
    ----------
    *packages : str
        Names of apt packages to remove.
    """
    run("apt-get", "remove", "-y", *packages, sudo=True)


def apt_update() -> None:
    """Update apt package lists."""
    run("apt-get", "update", "-y", sudo=True)


def apt_upgrade() -> None:
    """Upgrade apt packages."""
    run("apt-get", "upgrade", "-y", sudo=True)


def apt_full_upgrade() -> None:
    """Full-upgrade apt packages."""
    run("apt-get", "full-upgrade", "-y", sudo=True)


def apt_clean() -> None:
    """Clean apt cache."""
    run("apt-get", "clean", sudo=True)
    run("apt-get", "autoremove", "-y", sudo=True)


def apt_list_installed() -> list[str]:
    """List installed apt packages.

    Returns
    -------
    list[str]
        Names of packages marked as installed in ``dpkg --get-selections``
        output.
    """
    result = run("dpkg", "--get-selections", capture=True)
    return [line.split()[0] for line in result.stdout.splitlines() if "install" in line]


def dnf_install(*packages: str) -> None:
    """Install packages with dnf.

    Parameters
    ----------
    *packages : str
        Names of dnf packages to install.
    """
    run("dnf", "install", "-y", *packages, sudo=True)


def dnf_remove(*packages: str) -> None:
    """Remove packages with dnf.

    Parameters
    ----------
    *packages : str
        Names of dnf packages to remove.
    """
    run("dnf", "remove", "-y", *packages, sudo=True)


def dnf_update() -> None:
    """Update dnf packages."""
    run("dnf", "update", "-y", sudo=True)


def apk_install(*packages: str) -> None:
    """Install packages with apk (Alpine).

    Parameters
    ----------
    *packages : str
        Names of apk packages to install.
    """
    run("apk", "add", *packages, sudo=True)


def apk_remove(*packages: str) -> None:
    """Remove packages with apk (Alpine).

    Parameters
    ----------
    *packages : str
        Names of apk packages to remove.
    """
    run("apk", "del", *packages, sudo=True)


def apk_update() -> None:
    """Update apk package index."""
    run("apk", "update", sudo=True)


def pacman_install(*packages: str) -> None:
    """Install packages with pacman (Arch).

    Parameters
    ----------
    *packages : str
        Names of pacman packages to install.
    """
    run("pacman", "-S", "--noconfirm", *packages, sudo=True)


def pacman_remove(*packages: str) -> None:
    """Remove packages with pacman (Arch).

    Parameters
    ----------
    *packages : str
        Names of pacman packages to remove.
    """
    run("pacman", "-R", "--noconfirm", *packages, sudo=True)


def pacman_update() -> None:
    """Update pacman packages."""
    run("pacman", "-Syu", "--noconfirm", sudo=True)


def zypper_install(*packages: str) -> None:
    """Install packages with zypper (openSUSE).

    Parameters
    ----------
    *packages : str
        Names of zypper packages to install.
    """
    run("zypper", "install", "-y", *packages, sudo=True)


def zypper_remove(*packages: str) -> None:
    """Remove packages with zypper (openSUSE).

    Parameters
    ----------
    *packages : str
        Names of zypper packages to remove.
    """
    run("zypper", "remove", "-y", *packages, sudo=True)


def zypper_update() -> None:
    """Update zypper packages."""
    run("zypper", "update", "-y", sudo=True)


# -- System configuration ----------------------------------------------------


def configure_system_sshd(
    *,
    permit_root_login: str = "no",
    password_auth: str = "no",
    port: int = 22,
) -> None:
    """Configure sshd.

    Parameters
    ----------
    permit_root_login : str, optional
        Value for the sshd ``PermitRootLogin`` directive.
    password_auth : str, optional
        Value for the sshd ``PasswordAuthentication`` directive.
    port : int, optional
        TCP port for sshd to listen on.
    """
    config = f"""\
Port {port}
PermitRootLogin {permit_root_login}
PasswordAuthentication {password_auth}
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_* KOOPA_COLOR_MODE
Subsystem sftp /usr/lib/openssh/sftp-server
"""
    Path("/etc/ssh/sshd_config.d/99-koopa.conf").write_text(config)
    systemctl_restart("sshd")


def configure_lmod(prefix: str) -> None:
    """Configure Lmod environment modules.

    Parameters
    ----------
    prefix : str
        Installation prefix directory containing the Lmod ``init/profile``
        script.
    """
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
    """Install a Linux application using system package manager.

    Parameters
    ----------
    name : str
        Package name to install.
    manager : str, optional
        Package manager to use (``"apt"``, ``"dnf"``, ``"apk"``,
        ``"pacman"``, or ``"zypper"``).
    """
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
    """Uninstall a Linux application using system package manager.

    Parameters
    ----------
    name : str
        Package name to uninstall.
    manager : str, optional
        Package manager to use (``"apt"``, ``"dnf"``, ``"apk"``,
        ``"pacman"``, or ``"zypper"``).
    """
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
