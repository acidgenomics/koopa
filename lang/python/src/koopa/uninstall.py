"""Application uninstallation functions.

Provides ``uninstall_app`` — the Python equivalent of the Bash function
``_koopa_uninstall_app``. Removes an app's versioned prefix directory
and its symlinks from bin/, opt/, and man1/.
"""

import os
import shutil
import subprocess
import sys
from dataclasses import dataclass

from koopa.app import app_json_bin, app_json_man1
from koopa.prefix import (
    app_prefix,
    bash_completions_prefix,
    bin_prefix,
    fish_completions_prefix,
    koopa_prefix,
    man1_prefix,
    opt_prefix,
    zsh_completions_prefix,
)
from koopa.system import is_admin, is_owner
from koopa.uninstallers import get_python_uninstaller, has_python_uninstaller


@dataclass
class UninstallConfig:
    """Configuration for application uninstallation."""

    name: str
    mode: str = "shared"
    prefix: str = ""
    platform: str = "common"
    uninstaller: str = ""
    verbose: bool = False
    quiet: bool = False
    unlink_in_bin: bool | None = None
    unlink_in_man1: bool | None = None
    unlink_in_opt: bool | None = None


def uninstall_app(config: UninstallConfig) -> None:
    """Uninstall an application.

    Removes the app's prefix directory and symlinks from bin/, opt/, and
    man1/. Optionally runs a custom uninstaller script if one exists.
    """
    if config.verbose:
        os.environ["KOOPA_VERBOSE"] = "1"
    app_dir = app_prefix()
    if config.mode == "shared":
        if not is_owner():
            msg = "Only the koopa owner can uninstall shared apps."
            raise PermissionError(msg)
        if not config.prefix:
            config.prefix = os.path.join(app_dir, config.name)
        if config.unlink_in_bin is None:
            config.unlink_in_bin = True
        if config.unlink_in_man1 is None:
            config.unlink_in_man1 = True
        if config.unlink_in_opt is None:
            config.unlink_in_opt = True
    elif config.mode == "system":
        if not is_owner():
            msg = "Only the koopa owner can uninstall system apps."
            raise PermissionError(msg)
        if not is_admin():
            msg = "Admin/root access required for system uninstalls."
            raise PermissionError(msg)
        config.unlink_in_bin = False
        config.unlink_in_man1 = False
        config.unlink_in_opt = False
    elif config.mode == "user":
        config.unlink_in_bin = False
        config.unlink_in_man1 = False
        config.unlink_in_opt = False
    if config.prefix and not os.path.isdir(config.prefix):
        if not config.quiet:
            print(
                f"'{config.name}' is not installed at '{config.prefix}'.",
                file=sys.stderr,
            )
        return
    if config.prefix:
        config.prefix = os.path.realpath(config.prefix)
    if not config.quiet:
        print(
            f"Uninstalling '{config.name}' at '{config.prefix}'.",
            file=sys.stderr,
        )
    uninstaller_bn = config.uninstaller or config.name
    if has_python_uninstaller(uninstaller_bn, config.platform, config.mode):
        uninstaller = get_python_uninstaller(uninstaller_bn, config.platform, config.mode)
        uninstaller(
            name=config.name,
            platform=config.platform,
            mode=config.mode,
            prefix=config.prefix,
            verbose=config.verbose,
        )
    if os.path.isdir(config.prefix):
        if config.mode == "system":
            subprocess.run(
                ["sudo", "rm", "-rf", config.prefix],
                check=True,
            )
        else:
            shutil.rmtree(config.prefix, ignore_errors=True)
    if config.mode == "shared":
        if config.unlink_in_opt:
            _unlink_in_opt(config.name)
        if config.unlink_in_bin:
            bins = app_json_bin(config.name)
            for b in bins:
                _unlink_in_bin(b)
        if config.unlink_in_man1:
            man1_names = app_json_man1(config.name)
            for m in man1_names:
                _unlink_in_man1(m)
        _unlink_broken_completions()
    if not config.quiet:
        print(
            f"Successfully uninstalled '{config.name}'.",
            file=sys.stderr,
        )


def _unlink_in_opt(name: str) -> None:
    """Remove symlink from koopa opt/ directory."""
    target = os.path.join(opt_prefix(), name)
    if os.path.islink(target):
        os.unlink(target)


def _unlink_in_bin(name: str) -> None:
    """Remove symlink from koopa bin/ directory."""
    target = os.path.join(bin_prefix(), name)
    if os.path.islink(target):
        os.unlink(target)


def _unlink_in_man1(name: str) -> None:
    """Remove symlink from koopa man1/ directory."""
    target = os.path.join(man1_prefix(), name)
    if os.path.islink(target):
        os.unlink(target)


def _unlink_broken_completions() -> None:
    """Remove broken symlinks from all shell completion central directories."""
    for completions_dir in (
        bash_completions_prefix(),
        fish_completions_prefix(),
        zsh_completions_prefix(),
    ):
        if not os.path.isdir(completions_dir):
            continue
        for entry in os.listdir(completions_dir):
            target = os.path.join(completions_dir, entry)
            if os.path.islink(target) and not os.path.exists(target):
                os.unlink(target)


def _is_shared_install() -> bool:
    """Check if koopa is a shared (non-user-home) install."""
    home = os.path.expanduser("~")
    return not koopa_prefix().startswith(home)


def uninstall_koopa() -> None:
    """Uninstall koopa itself."""
    kp = koopa_prefix()
    bootstrap = kp.rstrip(os.sep) + "-bootstrap"
    config = os.path.join(kp, "etc", "koopa")
    print("Removing bootstrap prefix.", file=sys.stderr)
    shutil.rmtree(bootstrap, ignore_errors=True)
    print("Removing config prefix.", file=sys.stderr)
    shutil.rmtree(config, ignore_errors=True)
    xdg_config_home = os.environ.get(
        "XDG_CONFIG_HOME",
        os.path.join(os.path.expanduser("~"), ".config"),
    )
    koopa_config = os.path.join(xdg_config_home, "koopa")
    if os.path.isdir(koopa_config):
        print(f"Removing {koopa_config}.", file=sys.stderr)
        shutil.rmtree(koopa_config, ignore_errors=True)
    xdg_data_home = os.environ.get(
        "XDG_DATA_HOME",
        os.path.join(os.path.expanduser("~"), ".local", "share"),
    )
    xdg_data_link = os.path.join(xdg_data_home, "koopa")
    if os.path.islink(xdg_data_link):
        print(f"Removing {xdg_data_link}.", file=sys.stderr)
        os.unlink(xdg_data_link)
    if _is_shared_install() and is_admin():
        if sys.platform == "linux":
            profile_d = "/etc/profile.d/zzz-koopa.sh"
            if os.path.exists(profile_d):
                print(f"Removing {profile_d}.", file=sys.stderr)
                subprocess.run(["sudo", "rm", "-f", profile_d], check=True)
        print(f"Removing {kp}.", file=sys.stderr)
        subprocess.run(["sudo", "rm", "-rf", kp], check=True)
    else:
        print(f"Removing {kp}.", file=sys.stderr)
        shutil.rmtree(kp, ignore_errors=True)


def uninstall_non_default_apps(yes: bool = False, verbose: bool = False) -> None:
    """Uninstall installed apps that are not default and not dependencies of defaults."""
    from koopa.app import app_deps, import_app_json, installed_apps, shared_apps
    from koopa.install import _acquire_install_lock, _release_install_lock

    installed = set(installed_apps())
    default_apps = set(shared_apps(mode="default")) & installed
    json_data = import_app_json()
    protected: set[str] = set(default_apps)
    for app in default_apps:
        if app in json_data:
            protected.update(app_deps(app))
    targets = sorted(installed - protected)
    if not targets:
        print("No non-default apps to uninstall.")
        return
    print(f"Apps to uninstall ({len(targets)}):")
    for app in targets:
        print(f"  {app}")
    if not yes and sys.stdin.isatty():
        answer = input("\nProceed? [y/N] ").strip().lower()
        if answer not in ("y", "yes"):
            print("Aborted.", file=sys.stderr)
            return
    acquired = _acquire_install_lock()
    try:
        for app in targets:
            config = UninstallConfig(name=app, mode="shared", verbose=verbose)
            uninstall_app(config)
    finally:
        if acquired:
            _release_install_lock()
