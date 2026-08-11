"""System detection and information functions.

Converted from POSIX shell and Bash functions for system identification,
architecture detection, and OS-level queries.
"""

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

# Env vars safe to pass through to build/install subprocesses (compilers,
# package managers). Allowlist, not blocklist: a project-scoped credential a
# direnv .envrc loaded into the shell (e.g. MYPROJECT_API_KEY) is never named
# here, so it never reaches a build subprocess regardless of what's present
# in the parent shell's environment.
_SAFE_BUILD_ENV_KEYS: frozenset[str] = frozenset(
    {
        # Identity / shell basics tools fall back to.
        "HOME",
        "USER",
        "LOGNAME",
        "SHELL",
        "TERM",
        "TMPDIR",
        "PATH",
        # Locale.
        "LANG",
        "LC_ALL",
        "LC_CTYPE",
        # Compiler / build toolchain.
        "CC",
        "CXX",
        "FC",
        "F77",
        "CFLAGS",
        "CXXFLAGS",
        "CPPFLAGS",
        "LDFLAGS",
        "LDLIBS",
        "LIBRARY_PATH",
        "LD_LIBRARY_PATH",
        "DYLD_LIBRARY_PATH",
        "DYLD_FALLBACK_LIBRARY_PATH",
        "PKG_CONFIG_PATH",
        "CMAKE_PREFIX_PATH",
        "CPATH",
        "C_INCLUDE_PATH",
        "CPLUS_INCLUDE_PATH",
        "INCLUDE",
        "MACOSX_DEPLOYMENT_TARGET",
        "FORCE_UNSAFE_CONFIGURE",
        "ac_cv_func_stat64",
        # Environment Modules (HPC clusters).
        "LOADEDMODULES",
        "MODULEPATH",
        # Corporate TLS interception / proxies. Omitting these breaks every
        # network-fetching installer running behind a corporate proxy.
        "SSL_CERT_FILE",
        "CURL_CA_BUNDLE",
        "REQUESTS_CA_BUNDLE",
        "NODE_EXTRA_CA_CERTS",
        "GIT_SSL_CAINFO",
        "http_proxy",
        "https_proxy",
        "no_proxy",
        "HTTP_PROXY",
        "HTTPS_PROXY",
        "NO_PROXY",
        # XDG base dirs.
        "XDG_CACHE_HOME",
        "XDG_CONFIG_HOME",
        "XDG_DATA_HOME",
        "XDG_STATE_HOME",
        # Language toolchain homes that may be pre-set at the system level.
        "CONDA_EXE",
        "CONDA_PREFIX",
        "JAVA_HOME",
        "GOPATH",
        "GOBIN",
        "GOCACHE",
        "GOFLAGS",
        "GOPROXY",
        "GOSUMDB",
        "GO111MODULE",
        "OPENSSL_DIR",
        "PYTHONPATH",
    },
)

# Namespaced config surfaces owned by specific build tools. Prefix-matched,
# so e.g. every KOOPA_INSTALL_* var koopa itself sets is covered without
# enumerating each one; a project credential would need to happen to be
# named under one of these prefixes to slip through, which none of the
# leaks we've seen (MYPROJECT_API_KEY, MYPROJECT_SENTRY_DSN) are.
_SAFE_BUILD_ENV_PREFIXES: tuple[str, ...] = (
    "KOOPA_",
    "_KOOPA_",
    "HOMEBREW_",
    "CONDA_",
    "NPM_CONFIG_",
    "CARGO_",
    "RUSTUP_",
    "GHCUP_",
    "CABAL_",
    "STACK_",
    "JULIAUP_",
    "PLAYWRIGHT_",
    "PIP_",
)


def safe_build_env() -> dict[str, str]:
    """Return a copy of the environment safe to pass to build subprocesses.

    Filters ``os.environ`` down to an allowlist of names and namespaced
    prefixes that koopa's own installers rely on. Callers that redirect a
    build tool's cache/home directory (e.g. ``CARGO_HOME``, ``GOPATH``)
    should set that key on the returned dict afterward, same as they
    previously did on a raw ``os.environ.copy()``.
    """
    return {
        k: v
        for k, v in os.environ.items()
        if k in _SAFE_BUILD_ENV_KEYS or k.startswith(_SAFE_BUILD_ENV_PREFIXES)
    }


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


# Matches the variant-wrapped uint32 value in gdbus's `Settings.Read` output,
# e.g. '(<<uint32 1>>,)'. Anchoring on 'uint32' avoids a bare digit search
# matching a character inside the type name itself.
_PORTAL_COLOR_SCHEME_RE = re.compile(r"uint32\s+(\d+)")


def is_windows() -> bool:
    """Check if running on Windows."""
    return platform.system() == "Windows"


def os_appearance_mode() -> str:
    """Return the current OS appearance as 'dark' or 'light'.

    Distinct from ``color_mode()`` which returns terminal color depth.
    Reads directly from the OS at call time — never trusts inherited env.
    """
    if platform.system() == "Darwin":
        # `defaults read` exits non-zero when the key is absent (light mode).
        # Absence-of-key *is* the light signal — intentional check=False.
        result = subprocess.run(
            ["/usr/bin/defaults", "read", "-g", "AppleInterfaceStyle"],
            capture_output=True,
            text=True,
            check=False,
        )
        return "dark" if result.stdout.strip() == "Dark" else "light"
    if platform.system() == "Linux":
        return _os_appearance_mode_linux()
    if sys.platform == "win32":
        # Guard on sys.platform (not platform.system()) so pyright and ty narrow
        # the branch and resolve winreg without ignores; runtime result is identical.
        import winreg  # Windows-only stdlib; lazy import.

        try:
            with winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize",
            ) as key:
                value, _ = winreg.QueryValueEx(key, "AppsUseLightTheme")
            return "light" if value == 1 else "dark"
        except OSError:
            return "dark"
    return "dark"


def _linux_has_graphical_session() -> bool:
    """Return True when a graphical desktop session appears to be present.

    The XDG desktop portal is only meaningful inside a real desktop session.
    On headless hosts (SSH, SLURM login nodes, CI) the D-Bus session bus often
    still exists, so ``gdbus`` connects successfully and then blocks for the
    full D-Bus activation timeout (~28s measured) while systemd tries and
    fails to activate ``xdg-desktop-portal``. Gating on session type is what
    makes that cost avoidable; probing D-Bus availability is not sufficient,
    since the bus being reachable says nothing about whether a portal will
    ever answer.
    """
    if os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"):
        return True
    if os.environ.get("XDG_CURRENT_DESKTOP"):
        return True
    return os.environ.get("XDG_SESSION_TYPE", "") in ("wayland", "x11")


def _os_appearance_mode_linux() -> str:
    """Return 'dark' or 'light' on Linux via XDG portal or gsettings fallback."""
    if _linux_has_graphical_session():
        # Primary: XDG desktop portal (freedesktop standard; works on GNOME
        # and KDE). color-scheme: 0 = no-preference, 1 = prefer-dark,
        # 2 = prefer-light.
        gdbus = shutil.which("gdbus")
        if gdbus:
            try:
                result = subprocess.run(
                    [
                        gdbus,
                        "call",
                        "--session",
                        "--dest",
                        "org.freedesktop.portal.Desktop",
                        "--object-path",
                        "/org/freedesktop/portal/desktop",
                        "--method",
                        "org.freedesktop.portal.Settings.Read",
                        "org.freedesktop.appearance",
                        "color-scheme",
                    ],
                    capture_output=True,
                    text=True,
                    check=False,
                    timeout=5,
                )
            except subprocess.TimeoutExpired:
                result = None
            if result is not None and result.returncode == 0:
                match = _PORTAL_COLOR_SCHEME_RE.search(result.stdout)
                if match:
                    scheme = match.group(1)
                    # 0 = no-preference (fall through), 1 = prefer-dark,
                    # 2 = prefer-light.
                    if scheme == "1":
                        return "dark"
                    if scheme == "2":
                        return "light"
        # Fallback: gsettings (GNOME-only, but common).
        gsettings = shutil.which("gsettings")
        if gsettings:
            try:
                result = subprocess.run(
                    [gsettings, "get", "org.gnome.desktop.interface", "color-scheme"],
                    capture_output=True,
                    text=True,
                    check=False,
                    timeout=5,
                )
            except subprocess.TimeoutExpired:
                result = None
            if result is not None and result.returncode == 0:
                if "prefer-light" in result.stdout:
                    return "light"
                if "prefer-dark" in result.stdout:
                    return "dark"
    # Fallback: koopa color-mode cache file (written by the shell activation
    # layer from a terminal-background OSC 11 query).  Engages only on headless
    # hosts where no desktop session answers the portal or gsettings queries.
    cache_file = os.path.join(os.path.expanduser("~"), ".cache", "koopa", "color-mode")
    try:
        with open(cache_file) as fh:
            cached = fh.read().strip()
        if cached in ("light", "dark"):
            return cached
    except OSError:
        # Cache is optional; unreadable/missing cache falls back to default mode.
        pass
    return "dark"


def check_platform() -> None:
    """Raise RuntimeError if running on an unsupported platform.

    Unsupported platforms:
    - Windows (use WSL instead)
    - Linux with glibc < 2.28 (RHEL 7 / CentOS 7)
    - macOS on x86_64 (Intel Macs)

    Run 'koopa uninstall' to remove koopa from an unsupported system.
    """
    if sys.platform == "win32":
        msg = (
            "Windows is not supported."
            " Use Windows Subsystem for Linux (WSL) instead."
            " Run 'koopa uninstall' to remove."
        )
        raise RuntimeError(msg)
    elif sys.platform == "linux":
        try:
            ver_str = os.confstr("CS_GNU_LIBC_VERSION").split()[1]
            major, minor = (int(x) for x in ver_str.split(".")[:2])
            if (major, minor) < (2, 28):
                msg = (
                    f"This system has glibc {ver_str}."
                    " koopa requires glibc >= 2.28."
                    " RHEL 7 / CentOS 7 are not supported."
                    " Run 'koopa uninstall' to remove."
                )
                raise RuntimeError(msg)
        except (OSError, ValueError, AttributeError):
            # glibc version undetectable; skip enforcement.
            pass
    elif sys.platform == "darwin":
        if platform.machine() != "arm64":
            msg = (
                "Intel (x86_64) Macs are not supported."
                " koopa requires Apple Silicon (arm64)."
                " Run 'koopa uninstall' to remove."
            )
            raise RuntimeError(msg)


def is_root() -> bool:
    """Check if effective user is root."""
    return os.geteuid() == 0


def is_owner() -> bool:
    """Check if current user is the koopa installation owner."""
    from koopa.prefix import koopa_prefix

    try:
        return os.stat(koopa_prefix()).st_uid == os.getuid()
    except OSError:
        return False


def is_admin() -> bool:
    """Check if user has admin privileges.

    On macOS, checks membership in the 'admin' group.
    On Linux, checks if the user can run sudo (membership in 'sudo' or
    'wheel' groups, which is the standard convention on Debian/Ubuntu and
    Fedora/RHEL respectively).
    """
    if is_root():
        return True
    if is_macos():
        try:
            return grp.getgrnam("admin").gr_gid in os.getgroups()
        except KeyError:
            return False
    if is_linux():
        user_groups = os.getgroups()
        for name in ("sudo", "wheel"):
            try:
                if grp.getgrnam(name).gr_gid in user_groups:
                    return True
            except KeyError:
                continue
    return False


def has_sudo() -> bool:
    """Check whether the current user has sudo access."""
    if is_root():
        return True
    if shutil.which("sudo") is None:
        return False
    result = subprocess.run(
        ["sudo", "-v", "-n"],
        capture_output=True,
        check=False,
    )
    if result.returncode == 0:
        return True
    # "password is required" means user is in sudoers but needs auth.
    # On corporate-managed macOS, "sudo -n true" gives this message even when
    # sudo is fully revoked; "sudo -v -n" does not.
    return b"password is required" in result.stderr


def is_installed(name: str) -> bool:
    """Check if a program is installed."""
    return shutil.which(name) is not None


def find_system_python(version: str) -> str | None:
    """Find a system Python interpreter matching a 'major.minor' version.

    Checks '/usr/bin/python3' first, then 'python<version>' and 'python3' as
    resolved on PATH. Kept in sync by hand with bin/koopa's own interpreter
    probe (__koopa_python_version_matches() there does the same major.minor
    comparison).

    Parameters
    ----------
    version : str
        Required 'major.minor' version, e.g. '3.12'.

    Returns
    -------
    str | None
        Path to a matching interpreter, or None if none is found.
    """
    candidates = ["/usr/bin/python3"]
    for name in (f"python{version}", "python3"):
        found = shutil.which(name)
        if found:
            candidates.append(found)
    for candidate in candidates:
        if not os.path.isfile(candidate):
            continue
        result = subprocess.run(
            [candidate, "--version"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            continue
        found_version = result.stdout.strip().split()[-1]
        if ".".join(found_version.split(".")[:2]) == version:
            return candidate
    return None


def is_interactive() -> bool:
    """Check if running in an interactive session."""
    return bool(hasattr(sys, "ps1") or sys.flags.interactive)


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


def get_os_id_like() -> str:
    """Get the OS ID_LIKE string (e.g. 'debian' for Ubuntu)."""
    return _os_id_like()


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


def os_slug() -> str:
    """Get machine-readable OS version slug.

    Returns
    -------
    str
        e.g. 'macos-15', 'ubuntu-24', 'fedora-40'.
    """
    if is_macos():
        ver = platform.mac_ver()[0]
        major = ver.split(".")[0] if ver else ""
        return f"macos-{major}" if major else "macos"
    release = _read_os_release()
    os_id = release.get("ID", "linux")
    version = release.get("VERSION_ID", "")
    major = version.split(".")[0] if version else ""
    return f"{os_id}-{major}" if major else os_id


def os_id() -> str:
    """Platform and architecture-specific identifier (e.g. 'macos-arm64')."""
    _platform = "macos" if is_macos() else "linux"
    return f"{_platform}-{arch2()}"


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
        except (FileNotFoundError, subprocess.CalledProcessError, ValueError):
            pass
    meminfo = "/proc/meminfo"
    if os.path.isfile(meminfo):
        for line in Path(meminfo).read_text().splitlines():
            if line.startswith("MemTotal:"):
                match = re.search(r"(\d+)", line)
                if match:
                    kb = int(match.group(1))
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


def has_firewall() -> bool:
    """Check if the system is behind a corporate firewall.

    This mirrors the Bash ``koopa_has_firewall`` function. Returns ``True``
    when the ``SSL_CERT_FILE`` environment variable is set to a path that does
    *not* reside under the koopa prefix (i.e. it was provided externally, such
    as by a corporate firewall).

    Returns
    -------
    bool
        ``True`` when a non-koopa SSL_CERT_FILE is configured.
    """
    from koopa.prefix import koopa_prefix

    ssl_cert_file = os.environ.get("SSL_CERT_FILE", "")
    if not ssl_cert_file:
        return False
    kp = koopa_prefix()
    return not ssl_cert_file.startswith(kp + "/")
