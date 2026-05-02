"""Configure Debian/Ubuntu base system."""

from __future__ import annotations

import shutil
import subprocess

from koopa.alert import alert, alert_success
from koopa.file_ops import write_string
from koopa.os_linux import (
    apt_clean,
    apt_full_upgrade,
    apt_install,
    apt_update,
    is_init_systemd,
)

_PACKAGES = (
    "bash",
    "ca-certificates",
    "coreutils",
    "curl",
    "findutils",
    "g++",
    "gcc",
    "gfortran",
    "git",
    "libc-dev",
    "libgmp-dev",
    "libudev-dev",
    "locales",
    "lsb-release",
    "make",
    "perl",
    "procps",
    "sudo",
    "systemd",
    "tzdata",
    "unzip",
    "zsh",
)


def _configure_timezone() -> None:
    """Set timezone to America/New_York via debconf and timedatectl."""
    debconf = shutil.which("debconf-set-selections")
    if debconf is not None:
        selections = (
            "tzdata tzdata/Areas select America\ntzdata tzdata/Zones/America select New_York\n"
        )
        subprocess.run(
            ["sudo", debconf],
            input=selections,
            text=True,
            check=True,
        )
    timedatectl = shutil.which("timedatectl")
    if timedatectl is not None:
        subprocess.run(
            ["sudo", timedatectl, "set-timezone", "America/New_York"],
            check=True,
        )


def _configure_locale() -> None:
    """Configure en_US.UTF-8 locale."""
    write_string("en_US.UTF-8 UTF-8\n", "/etc/locale.gen", sudo=True)
    locale_gen = shutil.which("locale-gen")
    if locale_gen is not None:
        subprocess.run(["sudo", locale_gen, "--purge"], check=True)
    dpkg_reconfigure = shutil.which("dpkg-reconfigure")
    if dpkg_reconfigure is not None:
        subprocess.run(
            [
                "sudo",
                dpkg_reconfigure,
                "--frontend=noninteractive",
                "locales",
            ],
            check=True,
        )
    update_locale = shutil.which("update-locale")
    if update_locale is not None:
        subprocess.run(
            ["sudo", update_locale, "LANG=en_US.UTF-8"],
            check=True,
        )


def _configure_sshd() -> None:
    """Configure system sshd."""
    from koopa.configurers.sshd import main as configure_sshd

    configure_sshd(name="sshd", platform="linux", mode="system")


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure Debian/Ubuntu base system."""
    alert("Configuring system defaults.")
    apt_update()
    apt_full_upgrade()
    if is_init_systemd():
        _configure_timezone()
    apt_install(*_PACKAGES)
    apt_clean()
    if is_init_systemd():
        _configure_timezone()
    _configure_locale()
    _configure_sshd()
    alert_success("Configuration of system defaults was successful.")
