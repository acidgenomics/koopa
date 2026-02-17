"""System detection and information functions.

Converted from POSIX shell and Bash functions for system identification,
architecture detection, and OS-level queries.
"""

from __future__ import annotations

import grp
import os
import platform
import pwd
import re
import shutil
import subprocess
import sys
from datetime import UTC, datetime
from functools import lru_cache
from pathlib import Path


def arch() -> str:
    """Return system architecture string.

    Returns
    -------
    str
        Architecture (e.g. 'x86_64', 'arm64').
    """
    machine = platform.machine()
    return machine


def arch2() -> str:
    """Return normalized architecture for koopa conventions.

    Maps x86_64 -> amd64, aarch64 -> arm64, etc.

    Returns
    -------
    str
        Normalized architecture string.
    """
    machine = platform.machine().lower()
    mapping = {
        "x86_64": "amd64",
        "amd64": "amd64",
        "aarch64": "arm64",
        "arm64": "arm64",
        "i386": "386",
        "i686": "386",
    }
    return mapping.get(machine, machine)


def cpu_count() -> int:
    """Return number of available CPUs.

    Returns
    -------
    int
        CPU count.
    """
    return os.cpu_count() or 1


def default_shell_name() -> str:
    """Return the default login shell name.

    Returns
    -------
    str
        Shell name (e.g. 'bash', 'zsh').
    """
    shell = os.environ.get("SHELL", "/bin/sh")
    return os.path.basename(shell)


def shell_name() -> str:
    """Return the current shell name.

    Returns
    -------
    str
        Shell name.
    """
    shell = os.environ.get("KOOPA_SHELL", "")
    if shell:
        return os.path.basename(shell)
    return default_shell_name()


def group_id() -> int:
    """Return effective group ID."""
    return os.getegid()


def group_name() -> str:
    """Return effective group name."""
    return grp.getgrgid(os.getegid()).gr_name


def user_id() -> int:
    """Return effective user ID."""
    return os.geteuid()


def user_name() -> str:
    """Return effective user name."""
    return pwd.getpwuid(os.geteuid()).pw_name


def is_linux() -> bool:
    """Check if running on Linux."""
    return platform.system() == "Linux"


def is_macos() -> bool:
    """Check if running on macOS."""
    return platform.system() == "Darwin"


def is_root() -> bool:
    """Check if effective user is root."""
    return os.geteuid() == 0


def is_admin() -> bool:
    """Check if user has admin privileges."""
    if is_root():
        return True
    if is_macos():
        try:
            result = subprocess.run(
                ["groups"],
                capture_output=True,
                text=True,
                check=False,
            )
            return "admin" in result.stdout.split()
        except FileNotFoundError:
            return False
    return False


def is_installed(name: str) -> bool:
    """Check if a program is installed."""
    return shutil.which(name) is not None


def is_interactive() -> bool:
    """Check if running in an interactive session."""
    return hasattr(sys, "ps1") or sys.flags.interactive


def is_alpine() -> bool:
    """Check if running on Alpine Linux."""
    return _os_id() == "alpine"


def is_amzn() -> bool:
    """Check if running on Amazon Linux."""
    return _os_id() == "amzn"


def is_arch() -> bool:
    """Check if running on Arch Linux."""
    return _os_id() == "arch"


def is_centos() -> bool:
    """Check if running on CentOS."""
    return _os_id() == "centos"


def is_debian() -> bool:
    """Check if running on Debian."""
    return _os_id() == "debian"


def is_fedora() -> bool:
    """Check if running on Fedora."""
    return _os_id() == "fedora"


def is_opensuse() -> bool:
    """Check if running on openSUSE."""
    return _os_id() in ("opensuse-leap", "opensuse-tumbleweed", "opensuse")


def is_rhel() -> bool:
    """Check if running on RHEL."""
    return _os_id() == "rhel"


def is_ubuntu() -> bool:
    """Check if running on Ubuntu."""
    return _os_id() == "ubuntu"


def is_debian_like() -> bool:
    """Check if running on a Debian-like distro."""
    like = _os_id_like()
    return "debian" in like or is_debian()


def is_fedora_like() -> bool:
    """Check if running on a Fedora-like distro."""
    like = _os_id_like()
    return "fedora" in like or "rhel" in like or is_fedora() or is_rhel()


def is_os(os_id: str) -> bool:
    """Check if running on a specific OS."""
    return _os_id() == os_id


def is_os_like(os_id: str) -> bool:
    """Check if running on a specific OS family."""
    return os_id in _os_id_like()


def get_os_id() -> str:
    """Get the OS identifier string."""
    return _os_id()


@lru_cache(maxsize=1)
def _os_id() -> str:
    """Get OS ID from /etc/os-release."""
    if is_macos():
        return "macos"
    release = _read_os_release()
    return release.get("ID", "unknown").lower().strip('"')


@lru_cache(maxsize=1)
def _os_id_like() -> str:
    """Get OS ID_LIKE from /etc/os-release."""
    if is_macos():
        return "macos"
    release = _read_os_release()
    return release.get("ID_LIKE", "").lower().strip('"')


@lru_cache(maxsize=1)
def _read_os_release() -> dict[str, str]:
    """Parse /etc/os-release."""
    result: dict[str, str] = {}
    for path in ("/etc/os-release", "/usr/lib/os-release"):
        if os.path.isfile(path):
            for line in Path(path).read_text().splitlines():
                if "=" in line:
                    key, _, value = line.partition("=")
                    result[key.strip()] = value.strip().strip('"')
            break
    return result


def os_string() -> str:
    """Get a human-readable OS string.

    Returns
    -------
    str
        e.g. 'Ubuntu 22.04' or 'macOS 14.0'.
    """
    if is_macos():
        ver = platform.mac_ver()[0]
        return f"macOS {ver}"
    release = _read_os_release()
    name = release.get("PRETTY_NAME", "")
    if name:
        return name
    os_id = release.get("ID", "Linux")
    version = release.get("VERSION_ID", "")
    return f"{os_id} {version}".strip()


def logged_in_users() -> list[str]:
    """Get list of logged-in users."""
    try:
        result = subprocess.run(
            ["who"],
            capture_output=True,
            text=True,
            check=False,
        )
        users = set()
        for line in result.stdout.strip().splitlines():
            parts = line.split()
            if parts:
                users.add(parts[0])
        return sorted(users)
    except FileNotFoundError:
        return []


def check_multiple_users() -> bool:
    """Check if multiple users are logged in."""
    return len(logged_in_users()) > 1


def locate_shell(name: str) -> str | None:
    """Locate a shell executable."""
    return shutil.which(name)


def macos_is_dark_mode() -> bool:
    """Check if macOS is in dark mode."""
    if not is_macos():
        return False
    try:
        result = subprocess.run(
            ["defaults", "read", "-g", "AppleInterfaceStyle"],
            capture_output=True,
            text=True,
            check=False,
        )
        return result.stdout.strip().lower() == "dark"
    except FileNotFoundError:
        return False


def macos_os_version() -> str:
    """Get macOS version string."""
    if not is_macos():
        return ""
    return platform.mac_ver()[0]


def major_version(version: str) -> str:
    """Extract major version."""
    parts = version.split(".")
    return parts[0] if parts else version


def major_minor_version(version: str) -> str:
    """Extract major.minor version."""
    parts = version.split(".")
    return ".".join(parts[:2]) if len(parts) >= 2 else version


def major_minor_patch_version(version: str) -> str:
    """Extract major.minor.patch version."""
    parts = version.split(".")
    return ".".join(parts[:3]) if len(parts) >= 3 else version


def mem_gb() -> float:
    """Get total memory in GB."""
    if is_macos():
        try:
            result = subprocess.run(
                ["sysctl", "-n", "hw.memsize"],
                capture_output=True,
                text=True,
                check=True,
            )
            return round(int(result.stdout.strip()) / (1024**3), 1)
        except FileNotFoundError, subprocess.CalledProcessError, ValueError:
            pass
    meminfo = "/proc/meminfo"
    if os.path.isfile(meminfo):
        for line in Path(meminfo).read_text().splitlines():
            if line.startswith("MemTotal:"):
                kb = int(re.search(r"(\d+)", line).group(1))
                return round(kb / (1024**2), 1)
    return 0.0


def color_mode() -> str:
    """Detect terminal color mode."""
    colorterm = os.environ.get("COLORTERM", "").lower()
    if colorterm in ("truecolor", "24bit"):
        return "truecolor"
    term = os.environ.get("TERM", "")
    if "256color" in term:
        return "256"
    if term in ("xterm", "screen", "vt100"):
        return "8"
    return "none"


def today() -> str:
    """Get today's date in ISO format."""
    return datetime.now(tz=UTC).strftime("%Y-%m-%d")


def boolean_nounset(value: str | bool | int | None) -> bool:
    """Convert shell-style boolean to Python bool.

    Parameters
    ----------
    value : str | bool | int | None
        Input value. Truthy: '1', 'true', 'yes'. Falsy: '0', 'false', 'no', '', None.

    Returns
    -------
    bool
        Converted boolean.
    """
    if value is None:
        return False
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    return str(value).lower().strip() in ("1", "true", "yes")
