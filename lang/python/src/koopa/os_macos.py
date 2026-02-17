"""macOS-specific system management functions.

Converted from Bash functions in lang/bash/functions/os/macos/:
xcode CLT, rosetta, plist management, spotlight, finder, system preferences, etc.
"""

from __future__ import annotations

import os
import plistlib
import shutil
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
    """Get macOS version string."""
    result = _run("sw_vers", "-productVersion", capture=True)
    return result.stdout.strip()


def os_codename() -> str:
    """Get macOS codename (e.g. Sequoia, Sonoma)."""
    ver = os_version()
    major = int(ver.split(".")[0])
    codenames = {
        15: "Sequoia",
        14: "Sonoma",
        13: "Ventura",
        12: "Monterey",
        11: "Big Sur",
    }
    return codenames.get(major, f"macOS {major}")


def sdk_prefix() -> str:
    """Get macOS SDK prefix."""
    result = _run("xcrun", "--show-sdk-path", capture=True)
    return result.stdout.strip()


def macos_python_prefix() -> str:
    """Get macOS framework Python prefix."""
    return "/Library/Frameworks/Python.framework/Versions/Current"


def macos_r_prefix() -> str:
    """Get macOS R framework prefix."""
    return "/Library/Frameworks/R.framework/Versions/Current/Resources"


def app_version(app_path: str) -> str:
    """Get macOS application version from Info.plist."""
    plist_path = os.path.join(app_path, "Contents", "Info.plist")
    with open(plist_path, "rb") as f:
        plist = plistlib.load(f)
    return plist.get("CFBundleShortVersionString", "")


# -- Xcode CLT ---------------------------------------------------------------


def is_xcode_clt_installed() -> bool:
    """Check if Xcode Command Line Tools are installed."""
    return os.path.isdir("/Library/Developer/CommandLineTools")


def install_xcode_clt() -> None:
    """Install Xcode Command Line Tools."""
    _run("xcode-select", "--install")


def xcode_clt_version() -> str:
    """Get Xcode CLT version."""
    result = _run("xcode-select", "--version", capture=True)
    return result.stdout.strip()


def xcode_clt_prefix() -> str:
    """Get Xcode CLT path."""
    result = _run("xcode-select", "-p", capture=True)
    return result.stdout.strip()


# -- Rosetta -----------------------------------------------------------------


def install_rosetta() -> None:
    """Install Rosetta 2 on Apple Silicon."""
    _run(
        "softwareupdate",
        "--install-rosetta",
        "--agree-to-license",
        sudo=True,
    )


def is_rosetta_installed() -> bool:
    """Check if Rosetta 2 is installed."""
    return os.path.isfile("/Library/Apple/usr/share/rosetta/rosetta")


# -- plist enable/disable infrastructure -------------------------------------


def _launchctl_load(plist_path: str) -> None:
    """Load a launchd plist."""
    _run("launchctl", "load", "-w", plist_path, sudo=True)


def _launchctl_unload(plist_path: str) -> None:
    """Unload a launchd plist."""
    _run("launchctl", "unload", "-w", plist_path, sudo=True)


def disable_spotlight() -> None:
    """Disable Spotlight indexing."""
    _run("mdutil", "-a", "-i", "off", sudo=True)


def enable_spotlight() -> None:
    """Enable Spotlight indexing."""
    _run("mdutil", "-a", "-i", "on", sudo=True)


def disable_google_keystone() -> None:
    """Disable Google Keystone (updater)."""
    overrides = "/Library/Google/GoogleSoftwareUpdate"
    if os.path.isdir(overrides):
        _launchctl_unload("/Library/LaunchAgents/com.google.keystone.agent.plist")
        _launchctl_unload("/Library/LaunchDaemons/com.google.keystone.daemon.plist")


def disable_microsoft_defender() -> None:
    """Disable Microsoft Defender."""
    plists = [
        "/Library/LaunchAgents/com.microsoft.wdav.tray.plist",
        "/Library/LaunchDaemons/com.microsoft.fresno.plist",
        "/Library/LaunchDaemons/com.microsoft.fresno.uninstall.plist",
    ]
    for plist in plists:
        if os.path.isfile(plist):
            _launchctl_unload(plist)


def enable_microsoft_defender() -> None:
    """Enable Microsoft Defender."""
    plists = [
        "/Library/LaunchAgents/com.microsoft.wdav.tray.plist",
        "/Library/LaunchDaemons/com.microsoft.fresno.plist",
    ]
    for plist in plists:
        if os.path.isfile(plist):
            _launchctl_load(plist)


# -- Touch ID ----------------------------------------------------------------


def enable_touch_id_sudo() -> None:
    """Enable Touch ID for sudo."""
    pam_file = "/etc/pam.d/sudo"
    line = "auth       sufficient     pam_tid.so\n"
    with open(pam_file) as f:
        content = f.read()
    if "pam_tid.so" not in content:
        lines = content.splitlines(keepends=True)
        lines.insert(1, line)
        Path(pam_file).write_text("".join(lines))


# -- Finder ------------------------------------------------------------------


def finder_show_hidden_files() -> None:
    """Show hidden files in Finder."""
    _run(
        "defaults",
        "write",
        "com.apple.finder",
        "AppleShowAllFiles",
        "-bool",
        "true",
    )
    _run("killall", "Finder")


def finder_hide_hidden_files() -> None:
    """Hide hidden files in Finder."""
    _run(
        "defaults",
        "write",
        "com.apple.finder",
        "AppleShowAllFiles",
        "-bool",
        "false",
    )
    _run("killall", "Finder")


def finder_show_path_bar() -> None:
    """Show path bar in Finder."""
    _run("defaults", "write", "com.apple.finder", "ShowPathbar", "-bool", "true")
    _run("killall", "Finder")


def finder_show_status_bar() -> None:
    """Show status bar in Finder."""
    _run("defaults", "write", "com.apple.finder", "ShowStatusBar", "-bool", "true")
    _run("killall", "Finder")


# -- DNS / Network -----------------------------------------------------------


def flush_dns() -> None:
    """Flush DNS cache on macOS."""
    _run("dscacheutil", "-flushcache", sudo=True)
    _run("killall", "-HUP", "mDNSResponder", sudo=True)


def force_eject(volume: str) -> None:
    """Force eject a volume."""
    _run("diskutil", "unmountDisk", "force", volume, sudo=True)


# -- Spotlight ---------------------------------------------------------------


def spotlight_find(name: str) -> list[str]:
    """Find files using Spotlight."""
    result = _run("mdfind", "-name", name, capture=True)
    return result.stdout.strip().splitlines()


def spotlight_usage() -> str:
    """Get Spotlight index usage statistics."""
    result = _run("mdutil", "-s", "/", capture=True)
    return result.stdout.strip()


# -- Brew cask ---------------------------------------------------------------


def brew_cask_install(cask: str) -> None:
    """Install a Homebrew cask."""
    _run("brew", "install", "--cask", cask)


def brew_cask_uninstall(cask: str) -> None:
    """Uninstall a Homebrew cask."""
    _run("brew", "uninstall", "--cask", cask)


def brew_cask_upgrade() -> None:
    """Upgrade all Homebrew casks."""
    _run("brew", "upgrade", "--cask")


def brew_cask_list() -> list[str]:
    """List installed Homebrew casks."""
    result = _run("brew", "list", "--cask", capture=True)
    return result.stdout.strip().splitlines()


# -- DMG / disk images -------------------------------------------------------


def create_dmg(
    source_dir: str,
    output_path: str,
    volume_name: str = "Archive",
) -> None:
    """Create a DMG disk image from a directory."""
    _run(
        "hdiutil",
        "create",
        "-volname",
        volume_name,
        "-srcfolder",
        source_dir,
        "-ov",
        "-format",
        "UDZO",
        output_path,
    )


# -- Launch services ---------------------------------------------------------


def clean_launch_services() -> None:
    """Reset Launch Services database."""
    lsregister = (
        "/System/Library/Frameworks/CoreServices.framework"
        "/Frameworks/LaunchServices.framework/Support/lsregister"
    )
    _run(lsregister, "-kill", "-r", "-domain", "local", "-domain", "system", "-domain", "user")


def list_launch_agents() -> list[str]:
    """List launch agents."""
    agents_dir = os.path.expanduser("~/Library/LaunchAgents")
    if os.path.isdir(agents_dir):
        return os.listdir(agents_dir)
    return []


def list_app_store_apps() -> list[str]:
    """List apps installed from the App Store."""
    result = _run("find", "/Applications", "-path", "*/Contents/_MASReceipt", capture=True)
    return [
        os.path.basename(os.path.dirname(os.path.dirname(p)))
        for p in result.stdout.strip().splitlines()
        if p
    ]


# -- iCloud / Dropbox symlinks -----------------------------------------------


def symlink_icloud(target_dir: str, link_name: str | None = None) -> None:
    """Create symlink to iCloud Drive."""
    icloud = os.path.expanduser("~/Library/Mobile Documents/com~apple~CloudDocs")
    link = link_name or os.path.expanduser("~/iCloud")
    if not os.path.islink(link):
        os.symlink(os.path.join(icloud, target_dir), link)


def symlink_dropbox(target_dir: str, link_name: str | None = None) -> None:
    """Create symlink to Dropbox."""
    dropbox = os.path.expanduser("~/Library/CloudStorage/Dropbox")
    link = link_name or os.path.expanduser("~/Dropbox")
    if not os.path.islink(link):
        os.symlink(os.path.join(dropbox, target_dir), link)


# -- macOS download ----------------------------------------------------------


def download_macos(version: str | None = None) -> None:
    """Download macOS installer."""
    args = ["softwareupdate", "--fetch-full-installer"]
    if version:
        args.extend(["--full-installer-version", version])
    _run(*args, sudo=True)


# -- System preferences / defaults -------------------------------------------


def configure_system_preferences() -> None:
    """Apply opinionated macOS system preferences."""
    cmds = [
        ["defaults", "write", "NSGlobalDomain", "AppleShowAllExtensions", "-bool", "true"],
        [
            "defaults",
            "write",
            "NSGlobalDomain",
            "NSAutomaticSpellingCorrectionEnabled",
            "-bool",
            "false",
        ],
        [
            "defaults",
            "write",
            "NSGlobalDomain",
            "NSAutomaticCapitalizationEnabled",
            "-bool",
            "false",
        ],
        [
            "defaults",
            "write",
            "NSGlobalDomain",
            "NSAutomaticDashSubstitutionEnabled",
            "-bool",
            "false",
        ],
        [
            "defaults",
            "write",
            "NSGlobalDomain",
            "NSAutomaticPeriodSubstitutionEnabled",
            "-bool",
            "false",
        ],
        [
            "defaults",
            "write",
            "NSGlobalDomain",
            "NSAutomaticQuoteSubstitutionEnabled",
            "-bool",
            "false",
        ],
        ["defaults", "write", "com.apple.dock", "autohide", "-bool", "true"],
        ["defaults", "write", "com.apple.dock", "show-recents", "-bool", "false"],
        [
            "defaults",
            "write",
            "com.apple.screencapture",
            "location",
            os.path.expanduser("~/Desktop"),
        ],
        ["defaults", "write", "com.apple.screencapture", "type", "-string", "png"],
    ]
    for cmd in cmds:
        _run(*cmd)


def configure_user_preferences() -> None:
    """Apply opinionated macOS user preferences."""
    cmds = [
        ["defaults", "write", "com.apple.finder", "FXDefaultSearchScope", "-string", "SCcf"],
        [
            "defaults",
            "write",
            "com.apple.finder",
            "FXEnableExtensionChangeWarning",
            "-bool",
            "false",
        ],
        ["defaults", "write", "com.apple.finder", "ShowPathbar", "-bool", "true"],
        ["defaults", "write", "com.apple.finder", "ShowStatusBar", "-bool", "true"],
        [
            "defaults",
            "write",
            "com.apple.desktopservices",
            "DSDontWriteNetworkStores",
            "-bool",
            "true",
        ],
        ["defaults", "write", "com.apple.desktopservices", "DSDontWriteUSBStores", "-bool", "true"],
    ]
    for cmd in cmds:
        _run(*cmd)
    _run("killall", "Finder")


# -- App uninstall -----------------------------------------------------------

_MACOS_UNINSTALL_APPS = (
    "GarageBand",
    "iMovie",
    "Keynote",
    "Numbers",
    "Pages",
)


def uninstall_macos_app(name: str) -> None:
    """Uninstall a macOS application."""
    app_path = f"/Applications/{name}.app"
    if os.path.isdir(app_path):
        shutil.rmtree(app_path)
